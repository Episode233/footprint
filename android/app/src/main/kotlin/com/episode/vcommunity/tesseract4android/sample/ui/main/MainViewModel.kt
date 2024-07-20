package com.episode.vcommunity.tesseract4android.sample.ui.main

import android.app.Application
import android.graphics.Bitmap
import android.os.SystemClock
import android.util.Log
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.googlecode.tesseract.android.TessBaseAPI
import com.episode.vcommunity.tesseract4android.sample.utils.BaiDuApi
import java.util.Locale


class MainViewModel(application: Application) : AndroidViewModel(application) {
    val DESIRED_WIDTH_CROP_PERCENT = 8
    val DESIRED_HEIGHT_CROP_PERCENT = 74
    val tessApi: TessBaseAPI
    val processing = MutableLiveData(false)
    val progress = MutableLiveData<String>()
    val image = MutableLiveData<Bitmap>()
    val ocrText = MutableLiveData<String>()
    val translateText = MutableLiveData<String>()
    var isInitialized = false
    var lastText = ""
    var lastTranslateText = ""
    private lateinit var baiduApi: BaiDuApi

    val imageCropPercentages = MutableLiveData<Pair<Int, Int>>()
        .apply { value = Pair(DESIRED_HEIGHT_CROP_PERCENT, DESIRED_WIDTH_CROP_PERCENT) }

    @Volatile
    private var stopped = false

    @Volatile
    private var tessProcessing = false

    @Volatile
    private var recycleAfterProcessing = false
    private val recycleLock = Any()

    init {
        tessApi =
            TessBaseAPI { progressValues: TessBaseAPI.ProgressValues -> progress.postValue("Progress: " + progressValues.percent + " %") }

        baiduApi = BaiDuApi()
        // Show Tesseract version and library flavor at startup
        progress.value = String.format(
            Locale.ENGLISH, "Tesseract %s (%s)",
            tessApi.version, tessApi.libraryFlavor
        )
    }

    public override fun onCleared() {
        synchronized(recycleLock) {
            if (tessProcessing) {
                // Processing is active, set flag to recycle tessApi after processing is completed
                recycleAfterProcessing = true
                // Stop the processing as we don't care about the result anymore
                tessApi.stop()
            } else {
                // No ongoing processing, we must recycle it here
                tessApi.recycle()
            }
        }
    }

    fun initTesseract(dataPath: String, language: String, engineMode: Int) {
        Log.i(
            TAG, "Initializing Tesseract with: dataPath = [" + dataPath + "], " +
                    "language = [" + language + "], engineMode = [" + engineMode + "]"
        )
        try {
            this.isInitialized = tessApi.init(dataPath, language, engineMode)
            tessApi.pageSegMode = TessBaseAPI.PageSegMode.PSM_AUTO
        } catch (e: IllegalArgumentException) {
            this.isInitialized = false
            Log.e(TAG, "Cannot initialize Tesseract:", e)
        }
    }
    var time:Long = 0
    fun recognizeImage(imagePath: Bitmap) {
        if (System.currentTimeMillis()-time < 1000){
            return
        }
        time = System.currentTimeMillis()
        if (!this.isInitialized) {
            Log.e(TAG, "recognizeImage: Tesseract is not initialized")
            return
        }
        if (tessProcessing) {
            Log.e(TAG, "recognizeImage: Processing is in progress")
            return
        }
        tessProcessing = true
//        result.value = ""
//        ocrText.postValue("")
//        processing.value = true
//        progress.value = "Processing..."
        stopped = false

        // Start process in another thread
        Thread {
            try {
//                image.postValue(imagePath)
                tessApi.setImage(imagePath)
                // Or set it as Bitmap, Pix,...
                val startTime = SystemClock.uptimeMillis()
                // Use getHOCRText(0) method to trigger recognition with progress notifications and
                // ability to cancel ongoing processing.
                tessApi.getHOCRText(0)
                // At this point the recognition has completed (or was interrupted by calling stop())
                // and we can get the results we want. In this case just normal UTF8 text.
                //
                // Note that calling only this method (without the getHOCRText() above) would also
                // trigger the recognition and return the same result, but we would received no progress
                // notifications and we wouldn't be able to stop() the ongoing recognition.
//            // 获取识别的字符盒子信息
//            // 获取识别的字符盒子信息
//            val wordBoundingBoxes: List<Rect> = tessApi.words.getBoxRects()
//            val charBoundingBoxes: List<Rect> = tessApi.getCharacters().getBoxRects()

                val text = tessApi.utF8Text
                Log.e(TAG, "识别到文字: ${text}", )
                ocrText.postValue(text)
                if (text.trim().lowercase() != lastText.trim().lowercase()){
                    lastText = text.trim().lowercase()
                    ocrText.postValue(text)
                    if (baiduApi.baiduToken.isEmpty()){
                        baiduApi.getToken()
                    }
                    if (baiduApi.baiduToken.isNotEmpty()){
                        var tran = baiduApi.translate(text)
                        lastText = tran
                        translateText.postValue(tran)
                    }else{
                        translateText.postValue("获取token失败")
                    }
                }else{

                }

                tessApi.wordConfidences()
                // We can free up the recognition results and any stored image data in the tessApi
                // if we don't need them anymore.
                tessApi.clear()

//            processing.postValue(false)
                if (stopped) {
//                progress.postValue("Stopped.")
                } else {
                    val duration = SystemClock.uptimeMillis() - startTime
                    Log.e(TAG, "recognizeImage 消耗时间: ${duration}")
//                progress.postValue(
//                    String.format(
//                        Locale.ENGLISH,
//                        "Completed in %.3fs.", duration / 1000f
//                    )
//                )
                }
                synchronized(recycleLock) {
                    tessProcessing = false

                    // Recycle the instance here if the view model is already destroyed
                    if (recycleAfterProcessing) {
                        tessApi.recycle()
                    }
                }
            }catch (e:Exception){

            }
        }.start()
    }

    fun stop() {
        if (!tessProcessing) {
            return
        }
        progress.value = "Stopping..."
        stopped = true
        tessApi.stop()
    }

    fun getProcessing(): LiveData<Boolean> {
        return processing
    }

    fun getProgress(): LiveData<String> {
        return progress
    }

    fun getResult(): LiveData<String> {
        return ocrText
    }
    fun getImage(): LiveData<Bitmap> {
        return image
    }

    companion object {
        private const val TAG = "MainViewModel"
    }
}


