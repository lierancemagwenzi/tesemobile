package com.smatechgroup.smacredit;

import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import androidx.annotation.NonNull;
import com.ryanheise.audioservice.AudioServicePlugin;
import io.flutter.plugins.GeneratedPluginRegistrant; // Add this import
public class MainActivity extends FlutterFragmentActivity {

    @Override
    public FlutterEngine provideFlutterEngine(@NonNull android.content.Context context) {
        FlutterEngine engine = AudioServicePlugin.getFlutterEngine(context);

        // MANUALLY register all other plugins (device_info, etc.) to this engine
        if (engine != null) {
            GeneratedPluginRegistrant.registerWith(engine);
        }

        return engine;
    }
}