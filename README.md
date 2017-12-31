# trimcat

This command trims a list of videos with ffmpeg and concatenate them into
a single final video.

It takes 2 forms of input. The path for the final output video is taken as
the only command line argument. After launch, the command reads lines from
stdin until EOF. Each line of these input should be an absolute path to
a video file, and optionally, a start and end timestamp in the format of
hh:mm:ss. All 3 fields are separated by commas. Here's an example input:

```
/absolute/path/to/video,00:05:00,00:30:00
/absolute/path/to/another_video
```


Say, that input is in a file "input.txt", then this command can be used as

```
cat input.txt | trimcat output.mov
```

Then output.mov will be a video with content of "video" from beginning of the
5th minute to the 30th minute, followed by the content of "another_video"
with its entirety.

Obviously, it requires ffmpeg to have been installed on the system.
