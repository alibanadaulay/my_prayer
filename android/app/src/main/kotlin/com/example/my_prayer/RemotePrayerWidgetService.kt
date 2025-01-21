package com.example.my_prayer

import android.content.Context
import android.content.Intent
import android.widget.RemoteViewsService
import android.widget.RemoteViews

class WidgetRemoteViewsService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent?): RemoteViewsFactory {
        return WidgetRemoteViewsFactory(applicationContext, intent!!)
    }

    class WidgetRemoteViewsFactory(val context: Context, val intent: Intent) : RemoteViewsFactory {
        val itemList: List<String> = listOf("Item 1", "Item 2", "Item 3", "Item 4", "Item 5")

        override fun onCreate() {}

        override fun onDataSetChanged() {}

        override fun getCount(): Int {
            return itemList.size
        }

        override fun getViewAt(position: Int): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.prayer_item)
            views.setTextViewText(R.id.widget_item_title, itemList[position])

            // Add functionality here if needed (like setting onClickListener for each item)

            return views
        }

        override fun onDestroy() {}
        override fun getItemId(position: Int): Long = position.toLong()
        override fun hasStableIds(): Boolean = true
        override fun getLoadingView(): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.prayer_item_loading)
            return views
        }

        override fun getViewTypeCount(): Int =1
    }
}
