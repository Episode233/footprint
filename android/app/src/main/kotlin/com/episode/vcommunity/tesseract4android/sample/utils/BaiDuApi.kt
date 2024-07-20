package com.episode.vcommunity.tesseract4android.sample.utils

import com.lzy.okgo.OkGo
import com.lzy.okgo.cache.CacheMode
import org.json.JSONObject


class BaiDuApi {
    var baiduToken = ""
    val API_KEY = "t4AZmUE9566POaPxaBe9g0RC"
    val SECRET_KEY = "acCXe8iJArgbxa7ZjmoVmcDiX7lHvXNH"

    fun getToken(){
        try {
            var data = OkGo.post<String>("https://aip.baidubce.com/oauth/2.0/token?client_id=${API_KEY}&client_secret=${SECRET_KEY}&grant_type=client_credentials") // 请求方式和请求url
                .tag(this) // 请求的 tag, 主要用于取消对应的请求
                .cacheKey("cacheKey") // 设置当前请求的缓存key,建议每个不同功能的请求设置一个
                .cacheMode(CacheMode.DEFAULT) // 缓存模式，详细请看缓存介绍
                .execute();
            var ret = data.body!!.string()
            var json = JSONObject(ret)
            baiduToken = json.get("access_token").toString();
        }catch (e:Exception){
            e.printStackTrace()
        }
    }
    fun translate(query:String):String{
        if (query.isEmpty()){
            return ""
        }
        try {
            var jsons = JSONObject()
            jsons.put("from","en")
            jsons.put("to","zh")
            jsons.put("q",query)


            var data = OkGo.post<String>("https://aip.baidubce.com/rpc/2.0/mt/texttrans/v1?access_token=${baiduToken}") // 请求方式和请求url
                .upJson(jsons)
                .tag(this) // 请求的 tag, 主要用于取消对应的请求
                .cacheKey("cacheKey") // 设置当前请求的缓存key,建议每个不同功能的请求设置一个
                .cacheMode(CacheMode.DEFAULT) // 缓存模式，详细请看缓存介绍
                .execute();
            var retStr = data.body!!.string()
            var json = JSONObject(retStr)
            var jsonList = json.getJSONObject("result").getJSONArray("trans_result")
            var ret = ""
            for (i in 0 until jsonList.length()) {
                var json2 = JSONObject( jsonList.get(i).toString())
                ret += json2.get("dst").toString()
            }

            return ret
        }catch (e:Exception){
            e.printStackTrace()
            return "";
        }
    }


}