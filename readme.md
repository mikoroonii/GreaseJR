
# GreaseJR
#### ⚠️ Important! ⚠️ GreaseJR is in very early development, and thus is lacking many features and is likely riddled with bugs. Use at your own discretion.
---
GreaseJR is an OBS overlay designed to be used either as an audio-reactive avatar, with integration to StreamerBOT allowing for it to also be used to speak Text To Speech messages via ElevenLabs.

## Settings

You can get to the settings by clicking on the window (It's invisible, so the easiest way to find it is to click the icon in the taskbar and click in the middle of your screen) and pressing tab.
|Setting|Description|Default
|--|--|--|
|Microphone Device|The microphone GreaseJR will use when you're in Microphone Mode|Default
|Microphone Mode|Toggles Microphone Mode. Keeps GreaseJR on screen so you can talk through him|false
|Mouth Animation Threshold|The volume which your mic has to hit before GreaseJR's mouth starts moving|-25db
|Pose Animation Threshold|The volume which your mic has to hit before GreaseJR's pose changes|-25db
|Pose Cooldown|The cooldown between pose changes|0.5s
|Mouthshape Delay|The time between GreaseJR's mouthshape changes. The lower it is, the faster his mouth moves.|0.2s
|Model Variant|Switches between the "Greasy" model and the standard model.|Standard

## ElevenLabs Configuration
**You must have a subscription to ElevenLabs to use this feature**

Currently, there's no ElevenLabs configuration options in the app itself. You must directly edit `settings.cfg` with your ElevenLabs info. The `settings.cfg` file is created when you first run the app, so make sure you do that before trying to configure.

|Setting|Description|Default|
|--|--|--|
|API Key|Your ElevenLabs API key|N/A
|TTS Character Limit|The maximum amount of characters allowed in the TTS input. If it goes over, it will still play, but trimmed.|900
|Type|The platform to pick from. Just leave it at "elevenlabs" for now, as currently, that's all that's supported.|elevenlabs
|Voice ID|The voice ID you'd like to use|N/A
|Volume|A volume modifier for the generated TTS|0.35
|Model ID|Which speech model to use|eleven_v3
|Use Dialogue Mode|Whether to use the "Dialogue Mode" Feature|true

## StreamerBOT integration
This app doesn't yet support authenticated websockets, and listens at `ws://127.0.0.1:8080/`

A jr.grease file is included with the release. This is a StreamerBOT import file, and it contains the code to integrate with GreaseJR. It uses a simple websocket connection with the following payload:

```json
{
	customevent =  "greaseJR",
	tts = rawInput
}
```
If you're familiar with StreamerBOT, you'll recognize that this means it can be activated via a command or a channel redeem. Of course, it would be trivial to integrate it in other ways if you know some extremely basic C#, or are willing to learn.

If you've never used StreamerBOT before, I recommend watching [this video](https://www.youtube.com/watch?v=gfGy1gRH5ik) to get your bearings.

## Planned Features
- In-app configuration of ElevenLabs
- Support more TTS services
- Custom model support
- Profanity filters
- StreamerBOT websocket authentication & custom listening URL
