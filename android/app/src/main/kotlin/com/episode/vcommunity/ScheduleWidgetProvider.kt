package com.episode.vcommunity

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import com.episode.vcommunity.R
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
class ScheduleWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->

            val views = RemoteViews(context.packageName, R.layout.schedule_layout).apply {

                val message = widgetData.getString("message", null)
                // Detect App opened via Click inside Flutter
                val pendingIntentWithData = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("scheduleWidget://message?message=$message"))
                setOnClickPendingIntent(R.id.scheduleDate, pendingIntentWithData)
                val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("scheduleWidget://titleClicked")
                )
                setOnClickPendingIntent(R.id.widget_container, backgroundIntent)
                setTextViewText(
                    R.id.updateTime, widgetData.getString("updateTime", null)
                        ?: "")
                setTextViewText(
                    R.id.scheduleDate, widgetData.getString("scheduleDate", null)
                        ?: "")
                setTextViewText(
                    R.id.className_0, widgetData.getString("className_0", null)
                        ?: "")
                setTextViewText(
                    R.id.order_0, widgetData.getString("order_0", null)
                        ?: "")
                setTextViewText(
                    R.id.teacher_0, widgetData.getString("teacher_0", null)
                        ?: "")
                setTextViewText(
                    R.id.location_0, widgetData.getString("location_0", null)
                        ?: "")
                setTextViewText(
                    R.id.className_1, widgetData.getString("className_1", null)
                    ?: "")
                setTextViewText(
                    R.id.order_1, widgetData.getString("order_1", null)
                    ?: "")
                setTextViewText(
                    R.id.teacher_1, widgetData.getString("teacher_1", null)
                    ?: "")
                setTextViewText(
                    R.id.location_1, widgetData.getString("location_1", null)
                    ?: "")
                setTextViewText(
                    R.id.className_2, widgetData.getString("className_2", null)
                    ?: "")
                setTextViewText(
                    R.id.order_2, widgetData.getString("order_2", null)
                    ?: "")
                setTextViewText(
                    R.id.teacher_2, widgetData.getString("teacher_2", null)
                    ?: "")
                setTextViewText(
                    R.id.location_2, widgetData.getString("location_2", null)
                    ?: "")
                setTextViewText(
                    R.id.className_3, widgetData.getString("className_3", null)
                    ?: "")
                setTextViewText(
                    R.id.order_3, widgetData.getString("order_3", null)
                    ?: "")
                setTextViewText(
                    R.id.teacher_3, widgetData.getString("teacher_3", null)
                    ?: "")
                setTextViewText(
                    R.id.location_3, widgetData.getString("location_3", null)
                    ?: "")
                setTextViewText(
                    R.id.className_4, widgetData.getString("className_4", null)
                    ?: "")
                setTextViewText(
                    R.id.order_4, widgetData.getString("order_4", null)
                    ?: "")
                setTextViewText(
                    R.id.teacher_4, widgetData.getString("teacher_4", null)
                    ?: "")
                setTextViewText(
                    R.id.location_4, widgetData.getString("location_4", null)
                    ?: "")
                
            }
//            val layout4 = views.findViewById<LinearLayout>(R.id.layout_4)
//            if (widgetData.getString("className_4", null)
//                == null) {
//                layout4.visibility = View.GONE
//            } else {
//                layout4.visibility = View.VISIBLE
//            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}