import rtmidi
from rtmidi import midiconstants
import json
import time
import serial
from enum import Enum

ser = serial.Serial('COM8', baudrate=115200)

midi_in = rtmidi.MidiIn()

midi_in.open_port(name="PythonMidiPort")  # using loopMIDI for a virtual midi port

UPDATE_TYPES = {
    'DISPLAY_SEGMENTS_UPDATE': 0b0001_0000,
    'FACE_PANEL_UPDATE': 0b0011_0000,
    'LED_EFFECT': 0b0111_0000,
    'MOTORS': 0b1111_0000
}

MIDI_COMMANDS = {
    'NOTE_ON': 144,
    'NOTE_OFF': 128,
}

MIDI_NOTE_SEGMENT_LUT = {
    0: 'A',
    1: 'B',
    2: 'C',
    3: 'D',
    4: 'E',
    5: 'F',
    6: 'G',
    7: 'H',
    8: 'J',
    9: 'K',
    10: 'I',
    11: 'L',
    12: 'M',
    13: 'N',

}

VCR_MIDI_CONSTANTS = {
    'PAN_CC': 1,
    'TILT_CC': 2,
    'ROLL_CC': 3,
    'AMBULATE_CC': 4,

    'MACRO_EXPRESSIONS': {
        0: '1249',
        1: 'ANGRY CENTER',
        2: 'ANGRY LOOK LEFT',
        3: 'ANGRY LOOK RIGHT',
        4: 'BLINK CENTER',
        5: 'BLINK LEFT',
        6: 'BLINK RIGHT',
        7: 'EXTRA ANGRY CENTER',
        8: 'LOOK CENTER',
        9: 'LOOK DOWN LEFT',
        10: 'LOOK DOWN RIGHT',
        11: 'LOOK UP LEFT',
        12: 'LOOK UP RIGHT',
        13: 'SAD CENTER',
        14: 'SAD LOOK LEFT',
        15: 'SAD LOOK RIGHT',
        16: 'SMALL EYES CENTER',
        17: 'SMALL EYES LOOK DOWN LEFT',
        18: 'SMALL EYES LOOK DOWN RIGHT',
        19: 'SMALL EYES LOOK UP LEFT',
        20: 'SMALL EYES LOOK UP RIGHT',
        21: 'SMALL EYES UP CENTER',

    }
}

macro_file_path = "C:/Users/Public/MACROS V10"


def send_serial_status(status, data_length=1):
    ser.write(status)
    print("Status byte to send: " + str(status))


def send_serial_update(status, data_list, data_len=1):
    status_byte = status.to_bytes(length=1, byteorder='little', signed=False)
    send_serial_status(status_byte, data_len)

    for n in data_list:
        # print("Data: " + str(n) + ": " + str(data_list[n]))
        ser.write(data_list[n])


def get_binary_from_macro(macro, digit_num):
    binary_digit = 0

    digit = macro[str(digit_num)]
    for n in range(0, 14):
        if digit[str(n)]:
            binary_digit = binary_digit | 0b01 << int(n)

    return binary_digit


def handle_led_segments(midi_msg):

    note = midi_msg[1]
    vel = midi_msg[2]
    print("Note: " + str(note) + " | " + "Velocity: " + str(vel))

    macro_names = VCR_MIDI_CONSTANTS['MACRO_EXPRESSIONS']
    selected_macro = ''
    if note in macro_names.keys():
        selected_macro = macro_names[note]
    else:
        print("MIDI Note not assigned to valid macro expression.")
        return

    binary_digits = [0, 0, 0, 0]

    for i in range(4):
        binary_digits[i] = get_binary_from_macro(macro_data[selected_macro], i)
    # print("Binary Digit " + str(i) + ": " + bin(binary_digits[i]))

    digits_bytes_array = {}  # NOT A bytearray(), must be a dictionary
    for i in range(4):
        digits_bytes_array[i] = binary_digits[i].to_bytes(length=2,
                                                          byteorder='little',
                                                          signed=False)

    digits_bytes_array[4] = vel.to_bytes(length=1,
                                         byteorder='little',
                                         signed=False)
    # print("Velocity after bytes conversion:", digits_bytes_array[4])

    send_serial_update(status=UPDATE_TYPES['DISPLAY_SEGMENTS_UPDATE'],
                       data_list=digits_bytes_array,
                       data_len=9
                       )

    print("Macro Expression: " + macro_names[note])

    # -------- LED BRIGHTNESS / EFFECTS -------- (ARDUINO CODE NOT WRITTEN OR TESTED YET) !!!!




def handle_midi_cc_motor_control(midi_msg, delta_time):
    control = midi_msg[1]
    cc = midi_msg[2]
    print("Control change: " + str(control) + " | " + str(cc))

    motors_bytes_array = {}  # NOT A bytearray(), must be a dictionary

    motors_bytes_array[0] = control.to_bytes(length=1,
                                             byteorder='little',
                                             signed=False)
    motors_bytes_array[1] = cc.to_bytes(length=1,
                                        byteorder='little',
                                        signed=False)

    send_serial_update(status=UPDATE_TYPES['MOTORS'],
                       data_list=motors_bytes_array,
                       data_len=2)


with open(macro_file_path) as macro_file:
    macro_data = json.load(macro_file)

    while True:
        msg_and_dt = midi_in.get_message()

        if msg_and_dt:
            (msg, dt) = msg_and_dt
            # -------- MIDI NOTES - LED SEGMENTS --------
            if msg[0] == MIDI_COMMANDS['NOTE_ON']:
                handle_led_segments(msg)
            # -------- MIDI CC - MOTORS --------
            elif msg[0] == midiconstants.CONTROL_CHANGE and msg[1] != 123:
                # Control 123 gets set to zero when stopping playback. ignore 123 and 121
                handle_midi_cc_motor_control(msg, dt)

        #arduino_msg = ser.readline().decode('ascii')
        #print("Arduino Serial: " + str(arduino_msg))
