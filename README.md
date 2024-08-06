This repository stores the various pieces of code required to operate the segmented LED displays for the characters in my short film VCR2L: VideoCassette Rivals 2 Lovers.

This is the general control scheme:

```
GUI MIDI SEQUENCER (I.E. Ableton Live running on a laptop) 
-> MIDI TO BINARY TRANSLATOR (python script receiving MIDI) 
-> HOST ESP32 (serial from python script over USB) 
-> CLIENT ESP32 (wireless using ESP-NOW protocol)
-> SEGMENTED LED DISPLAY
```

This basically allows me to use a sequencer like Ableton to quickly create and easily repeat animations and patterns, by assigning notes and velocity data to pre-determined LED display patterns.
