import 'package:ant_media_flutter/ant_media_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:smacredit/client/events/live_stream_comments.dart';
import 'package:smacredit/src/content-creator/events/models/event_model.dart';
import 'package:smacredit/src/repositories/user_repository.dart';

class FullScreenBroadcast extends StatefulWidget {
  final StreamWatchUnlockModel streamWatchUnlockModel;
  final EventModel eventModel;

  const FullScreenBroadcast({
    Key? key,
    required this.streamWatchUnlockModel,
    required this.eventModel,
  }) : super(key: key);

  @override
  _FullScreenBroadcastState createState() => _FullScreenBroadcastState();
}

class _FullScreenBroadcastState extends State<FullScreenBroadcast> {
  // 1. Define the renderers
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    _initAndConnect();
  }

  Map<String, String> parseAntMediaUrl(String rtmpUrl) {
    // Example Input: rtmp://ams-54-167-81-151.antmedia.cloud/WebRTCAppEE/QlAmc9...

    // Replace rtmp with http so the Uri parser can handle it
    String webUrl = rtmpUrl.replaceFirst('rtmp://', 'http://');
    Uri uri = Uri.parse(webUrl);

    // The first part of the path is the App Name (e.g., WebRTCAppEE)
    // The second part is the Stream ID
    List<String> pathSegments = uri.pathSegments;
    String appName = pathSegments.isNotEmpty ? pathSegments[0] : 'WebRTCAppEE';
    String streamId = pathSegments.length > 1 ? pathSegments[1] : '';

    // Construct the Secure WebSocket URL
    // Port 5443 is the standard SSL port for Ant Media
    String wsUrl = "wss://${uri.host}:5443/$appName/websocket";

    return {
      'wsUrl': wsUrl,
      'streamId': streamId,
      'host': uri.host,
      'appName': appName,
    };
  }

  Future<void> _initAndConnect() async {
    // 2. Initialize the renderers before connecting

    // String myRtmp =
    //     "rtmp://ams-54-167-81-151.antmedia.cloud/WebRTCAppEE/QlAmc9tqlzUwJW9b75512223534";

    // // Parse it
    // var config = parseAntMediaUrl(myRtmp);
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    // 3. Connect using the exact positional arguments from your docs
    AntMediaFlutter.connect(
      widget.streamWatchUnlockModel.playbackUrl ?? "",
      widget.eventModel.streamId ?? "", // streamID
      '', // roomID
      widget.streamWatchUnlockModel.key ?? "", // token
      AntMediaType.Publish, // type
      false, // userScreen (Set to false for Camera)
      // onStateChange
      (HelperState state) {
        switch (state) {
          case HelperState.ConnectionOpen:
            setState(() => _isPublishing = true);
            // Trigger the actual publish command
            AntMediaFlutter.anthelper?.publish(
              widget.eventModel.streamId ?? "", // 1. streamId
              widget.streamWatchUnlockModel.key ?? "", // 2. token (Publish JWT)
              '', // 3. subscriberId (Optional, usually empty)
              '', // 4. subscriberCode (Optional, usually empty)
              '', // 5. streamName (Optional, defaults to streamId)
              '', // 6. mainTrack (Optional, for multitrack)
              '', // 7. metaData (Optional, JSON string for extra info)
            );
            break;
          case HelperState.ConnectionClosed:
            setState(() => _isPublishing = false);
            break;
          default:
            break;
        }
      },

      // onLocalStream
      ((stream) {
        setState(() {
          _localRenderer.srcObject = stream;
        });
      }),

      // onAddRemoteStream
      ((stream) {
        setState(() {
          _remoteRenderer.srcObject = stream;
        });
      }),

      // onDataChannel
      (datachannel) {
        print("Data Channel: ${datachannel.id}");
      },

      // onDataChannelMessage
      (channel, message, isReceived) {
        print("Message: ${message.text}");
      },

      // onupdateConferencePerson
      (streams) {},

      // onRemoveRemoteStream
      ((stream) {
        setState(() {
          _remoteRenderer.srcObject = null;
        });
      }),

      // ice servers
      [
        {'url': 'stun:stun.l.google.com:19302'},
      ],

      // callbacks
      (command, mapData) {
        print("Server Command: $command");
      },
    );
  }

  Map<String, dynamic> userMap = {
    'id': '${currentuser.value.user?.id?.toString()}',
    'name':
        '${currentuser.value.user?.fullname ?? ''}', // Full name or Username to display
    'image':
        currentuser.value.user?.selfie ??
        '', // URL to the user's profile picture
  };

  @override
  void dispose() {
    // 4. Clean up renderers to free up the camera
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // FULL SCREEN CAMERA PREVIEW
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: RTCVideoView(
                  _localRenderer,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),
          ),

          // UI OVERLAY
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _isPublishing ? Colors.red : Colors.grey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _isPublishing ? "LIVE" : "CONNECTING...",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // IconButton(
                      //   icon: const Icon(
                      //     Icons.flip_camera_ios,
                      //     color: Colors.white,
                      //     size: 30,
                      //   ),
                      //   onPressed: () =>
                      //       AntMediaFlutter.anthelper?.switchCamera(),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            right: 0,
            top: 100,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute Button
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    radius: 30,
                    child: IconButton(
                      icon: Icon(
                        _isMuted ? Icons.mic_off : Icons.mic,
                        color: _isMuted ? Colors.red : Colors.white,
                      ),
                      onPressed: _toggleMute,
                    ),
                  ),

                  // Close Button
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    radius: 30,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        AntMediaFlutter.anthelper?.bye();
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  // Camera Flip Button
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    radius: 30,
                    child: IconButton(
                      icon: const Icon(
                        Icons.flip_camera_ios,
                        color: Colors.white,
                      ),
                      onPressed: () =>
                          AntMediaFlutter.anthelper?.switchCamera(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            width:
                MediaQuery.of(context).size.width *
                0.85, // Stops it being too wide
            height:
                MediaQuery.of(context).size.height *
                0.45, // Comments take 45% of height
            child: TeseLiveCommentsOverlay(
              eventId: widget.eventModel.id.toString(),
              currentUser: userMap,
            ),
          ),
        ],
      ),
    );
  }

  bool _isMuted = false;

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    // This tells the Ant Media SDK to stop/start sending audio data
    AntMediaFlutter.anthelper?.muteMic(_isMuted);
  }
}
