package com.socialtree.dating_app_mobile

import android.content.Context
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.socialtree.dating_app_mobile/media_helper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "copyContentUriToTemp") {
                val uriString = call.argument<String>("uri")
                if (uriString == null) {
                    result.error("INVALID_ARGUMENT", "URI cannot be null", null)
                    return@setMethodCallHandler
                }
                try {
                    val uri = Uri.parse(uriString)
                    val filePath = copyUriToTempFile(applicationContext, uri)
                    if (filePath != null) {
                        result.success(filePath)
                    } else {
                        result.error("COPY_FAILED", "Failed to copy content URI", null)
                    }
                } catch (e: Exception) {
                    result.error("ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun copyUriToTempFile(context: Context, uri: Uri): String? {
        var inputStream: InputStream? = null
        var outputStream: FileOutputStream? = null
        try {
            inputStream = context.contentResolver.openInputStream(uri)
            if (inputStream == null) return null

            val mimeType = context.contentResolver.getType(uri)
            val extension = if (mimeType != null && mimeType.contains("video")) "mp4" else "jpg"

            val tempFile = File(context.cacheDir, "temp_picked_media_${System.currentTimeMillis()}.$extension")
            outputStream = FileOutputStream(tempFile)
            val buffer = ByteArray(4 * 1024)
            var bytesRead: Int
            while (inputStream.read(buffer).also { bytesRead = it } != -1) {
                outputStream.write(buffer, 0, bytesRead)
            }
            outputStream.flush()
            return tempFile.absolutePath
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        } finally {
            inputStream?.close()
            outputStream?.close()
        }
    }
}
