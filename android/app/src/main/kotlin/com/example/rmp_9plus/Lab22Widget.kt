package com.example.rmp_9plus

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.widget.RemoteViews

/**
 * Лабораторная работа №2.2 — виджет рабочего стола (AppWidgetProvider).
 *
 * Показывает статичный текст, по нажатию меняет цвет фона,
 * перебирая палитру [COLORS]. Цвет запоминается, чтобы пережить
 * пересоздание виджета.
 */
class Lab22Widget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_CHANGE_COLOR) {
            val appWidgetId = intent.getIntExtra(
                EXTRA_WIDGET_ID,
                AppWidgetManager.INVALID_APPWIDGET_ID,
            )
            if (appWidgetId != AppWidgetManager.INVALID_APPWIDGET_ID) {
                advanceColor(context)
                updateWidget(context, AppWidgetManager.getInstance(context), appWidgetId)
            }
        }
    }

    private fun updateWidget(
        context: Context,
        manager: AppWidgetManager,
        appWidgetId: Int,
    ) {
        val views = RemoteViews(context.packageName, R.layout.lab22_widget_layout)
        views.setTextViewText(R.id.widget_text, TEXT)
        views.setInt(R.id.widget_container, "setBackgroundColor", COLORS[colorIndex(context)])

        val changeColor = Intent(context, Lab22Widget::class.java).apply {
            action = ACTION_CHANGE_COLOR
            putExtra(EXTRA_WIDGET_ID, appWidgetId)
        }
        val pending = PendingIntent.getBroadcast(
            context,
            appWidgetId,
            changeColor,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        views.setOnClickPendingIntent(R.id.widget_container, pending)

        manager.updateAppWidget(appWidgetId, views)
    }

    companion object {
        const val ACTION_CHANGE_COLOR =
            "com.example.rmp_9plus.lab22.ACTION_CHANGE_COLOR"
        const val EXTRA_WIDGET_ID = "widget_id"

        private const val TEXT = "Hello, Widget!"
        private const val PREFS_NAME = "lab22_widget"
        private const val KEY_COLOR_INDEX = "color_index"

        // Палитра фона виджета (фон — на выбор по заданию)
        val COLORS = intArrayOf(
            Color.parseColor("#03A9F4"), // голубой
            Color.parseColor("#9C27B0"), // фиолетовый
            Color.parseColor("#009688"), // бирюзовый
            Color.parseColor("#FF5722"), // оранжевый
        )

        private fun prefs(context: Context) =
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        private fun colorIndex(context: Context) =
            prefs(context).getInt(KEY_COLOR_INDEX, 0)

        private fun advanceColor(context: Context) {
            val next = (colorIndex(context) + 1) % COLORS.size
            prefs(context).edit().putInt(KEY_COLOR_INDEX, next).apply()
        }
    }
}
