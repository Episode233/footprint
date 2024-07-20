package com.episode.vcommunity.tesseract4android.sample

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.episode.vcommunity.R
import java.util.logging.Level

import com.lzy.okgo.OkGo

import com.lzy.okgo.cache.CacheEntity

import com.lzy.okgo.cache.CacheMode

import com.lzy.okgo.interceptor.HttpLoggingInterceptor

import com.lzy.okgo.model.HttpHeaders
import com.episode.vcommunity.tesseract4android.sample.ui.main.MainFragment
import okhttp3.OkHttpClient

class OCRActivity : AppCompatActivity() {
    protected override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_ocr)
        if (savedInstanceState == null) {
            getSupportFragmentManager().beginTransaction()
                .replace(R.id.container, MainFragment.newInstance())
                .commitNow()
        }
        val builder  = OkHttpClient.Builder()
        val loggingInterceptor = HttpLoggingInterceptor("OkGo")
        loggingInterceptor.setPrintLevel(HttpLoggingInterceptor.Level.BODY)
        loggingInterceptor.setColorLevel(Level.INFO)
        builder.addInterceptor(loggingInterceptor)
        val headers = HttpHeaders()
        headers.put("Content-Type", "application/json")
        headers.put("Accept", "application/json")
        OkGo.getInstance().init(getApplication())
            .setOkHttpClient(builder.build())
            .setCacheMode(CacheMode.NO_CACHE)
            .setCacheTime(CacheEntity.CACHE_NEVER_EXPIRE)
            .setRetryCount(3)
            .addCommonHeaders(headers)
    }
}