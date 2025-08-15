package com.omiyawaki.osrswiki.history.db

import androidx.room.EntityDeleteOrUpdateAdapter
import androidx.room.EntityInsertAdapter
import androidx.room.RoomDatabase
import androidx.room.coroutines.createFlow
import androidx.room.util.getColumnIndexOrThrow
import androidx.room.util.performSuspending
import androidx.sqlite.SQLiteStatement
import com.omiyawaki.osrswiki.database.converters.DateConverter
import java.util.Date
import javax.`annotation`.processing.Generated
import kotlin.Boolean
import kotlin.Int
import kotlin.Long
import kotlin.String
import kotlin.Suppress
import kotlin.Unit
import kotlin.collections.List
import kotlin.collections.MutableList
import kotlin.collections.mutableListOf
import kotlin.reflect.KClass
import kotlinx.coroutines.flow.Flow

@Generated(value = ["androidx.room.RoomProcessor"])
@Suppress(names = ["UNCHECKED_CAST", "DEPRECATION", "REDUNDANT_PROJECTION", "REMOVAL"])
public class HistoryEntryDao_Impl(
  __db: RoomDatabase,
) : HistoryEntryDao {
  private val __db: RoomDatabase

  private val __insertAdapterOfHistoryEntry: EntityInsertAdapter<HistoryEntry>

  private val __updateAdapterOfHistoryEntry: EntityDeleteOrUpdateAdapter<HistoryEntry>
  init {
    this.__db = __db
    this.__insertAdapterOfHistoryEntry = object : EntityInsertAdapter<HistoryEntry>() {
      protected override fun createQuery(): String =
          "INSERT OR REPLACE INTO `history_entries` (`page_wikiUrl`,`page_displayText`,`page_pageId`,`page_apiPath`,`timestamp`,`source`,`is_archived`,`snippet`,`thumbnail_url`) VALUES (?,?,?,?,?,?,?,?,?)"

      protected override fun bind(statement: SQLiteStatement, entity: HistoryEntry) {
        statement.bindText(1, entity.wikiUrl)
        statement.bindText(2, entity.displayText)
        val _tmpPageId: Int? = entity.pageId
        if (_tmpPageId == null) {
          statement.bindNull(3)
        } else {
          statement.bindLong(3, _tmpPageId.toLong())
        }
        statement.bindText(4, entity.apiPath)
        val _tmp: Long? = DateConverter.dateToTimestamp(entity.timestamp)
        if (_tmp == null) {
          statement.bindNull(5)
        } else {
          statement.bindLong(5, _tmp)
        }
        statement.bindLong(6, entity.source.toLong())
        val _tmp_1: Int = if (entity.isArchived) 1 else 0
        statement.bindLong(7, _tmp_1.toLong())
        val _tmpSnippet: String? = entity.snippet
        if (_tmpSnippet == null) {
          statement.bindNull(8)
        } else {
          statement.bindText(8, _tmpSnippet)
        }
        val _tmpThumbnailUrl: String? = entity.thumbnailUrl
        if (_tmpThumbnailUrl == null) {
          statement.bindNull(9)
        } else {
          statement.bindText(9, _tmpThumbnailUrl)
        }
      }
    }
    this.__updateAdapterOfHistoryEntry = object : EntityDeleteOrUpdateAdapter<HistoryEntry>() {
      protected override fun createQuery(): String =
          "UPDATE OR ABORT `history_entries` SET `page_wikiUrl` = ?,`page_displayText` = ?,`page_pageId` = ?,`page_apiPath` = ?,`timestamp` = ?,`source` = ?,`is_archived` = ?,`snippet` = ?,`thumbnail_url` = ? WHERE `page_wikiUrl` = ?"

      protected override fun bind(statement: SQLiteStatement, entity: HistoryEntry) {
        statement.bindText(1, entity.wikiUrl)
        statement.bindText(2, entity.displayText)
        val _tmpPageId: Int? = entity.pageId
        if (_tmpPageId == null) {
          statement.bindNull(3)
        } else {
          statement.bindLong(3, _tmpPageId.toLong())
        }
        statement.bindText(4, entity.apiPath)
        val _tmp: Long? = DateConverter.dateToTimestamp(entity.timestamp)
        if (_tmp == null) {
          statement.bindNull(5)
        } else {
          statement.bindLong(5, _tmp)
        }
        statement.bindLong(6, entity.source.toLong())
        val _tmp_1: Int = if (entity.isArchived) 1 else 0
        statement.bindLong(7, _tmp_1.toLong())
        val _tmpSnippet: String? = entity.snippet
        if (_tmpSnippet == null) {
          statement.bindNull(8)
        } else {
          statement.bindText(8, _tmpSnippet)
        }
        val _tmpThumbnailUrl: String? = entity.thumbnailUrl
        if (_tmpThumbnailUrl == null) {
          statement.bindNull(9)
        } else {
          statement.bindText(9, _tmpThumbnailUrl)
        }
        statement.bindText(10, entity.wikiUrl)
      }
    }
  }

  public override suspend fun insertEntry(historyEntry: HistoryEntry): Unit =
      performSuspending(__db, false, true) { _connection ->
    __insertAdapterOfHistoryEntry.insert(_connection, historyEntry)
  }

  public override suspend fun updateEntry(historyEntry: HistoryEntry): Unit =
      performSuspending(__db, false, true) { _connection ->
    __updateAdapterOfHistoryEntry.handle(_connection, historyEntry)
  }

  public override fun getAllEntries(): Flow<List<HistoryEntry>> {
    val _sql: String = "SELECT * FROM history_entries ORDER BY timestamp DESC"
    return createFlow(__db, false, arrayOf("history_entries")) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        val _columnIndexOfWikiUrl: Int = getColumnIndexOrThrow(_stmt, "page_wikiUrl")
        val _columnIndexOfDisplayText: Int = getColumnIndexOrThrow(_stmt, "page_displayText")
        val _columnIndexOfPageId: Int = getColumnIndexOrThrow(_stmt, "page_pageId")
        val _columnIndexOfApiPath: Int = getColumnIndexOrThrow(_stmt, "page_apiPath")
        val _columnIndexOfTimestamp: Int = getColumnIndexOrThrow(_stmt, "timestamp")
        val _columnIndexOfSource: Int = getColumnIndexOrThrow(_stmt, "source")
        val _columnIndexOfIsArchived: Int = getColumnIndexOrThrow(_stmt, "is_archived")
        val _columnIndexOfSnippet: Int = getColumnIndexOrThrow(_stmt, "snippet")
        val _columnIndexOfThumbnailUrl: Int = getColumnIndexOrThrow(_stmt, "thumbnail_url")
        val _result: MutableList<HistoryEntry> = mutableListOf()
        while (_stmt.step()) {
          val _item: HistoryEntry
          val _tmpWikiUrl: String
          _tmpWikiUrl = _stmt.getText(_columnIndexOfWikiUrl)
          val _tmpDisplayText: String
          _tmpDisplayText = _stmt.getText(_columnIndexOfDisplayText)
          val _tmpPageId: Int?
          if (_stmt.isNull(_columnIndexOfPageId)) {
            _tmpPageId = null
          } else {
            _tmpPageId = _stmt.getLong(_columnIndexOfPageId).toInt()
          }
          val _tmpApiPath: String
          _tmpApiPath = _stmt.getText(_columnIndexOfApiPath)
          val _tmpTimestamp: Date
          val _tmp: Long?
          if (_stmt.isNull(_columnIndexOfTimestamp)) {
            _tmp = null
          } else {
            _tmp = _stmt.getLong(_columnIndexOfTimestamp)
          }
          val _tmp_1: Date? = DateConverter.fromTimestamp(_tmp)
          if (_tmp_1 == null) {
            error("Expected NON-NULL 'java.util.Date', but it was NULL.")
          } else {
            _tmpTimestamp = _tmp_1
          }
          val _tmpSource: Int
          _tmpSource = _stmt.getLong(_columnIndexOfSource).toInt()
          val _tmpIsArchived: Boolean
          val _tmp_2: Int
          _tmp_2 = _stmt.getLong(_columnIndexOfIsArchived).toInt()
          _tmpIsArchived = _tmp_2 != 0
          val _tmpSnippet: String?
          if (_stmt.isNull(_columnIndexOfSnippet)) {
            _tmpSnippet = null
          } else {
            _tmpSnippet = _stmt.getText(_columnIndexOfSnippet)
          }
          val _tmpThumbnailUrl: String?
          if (_stmt.isNull(_columnIndexOfThumbnailUrl)) {
            _tmpThumbnailUrl = null
          } else {
            _tmpThumbnailUrl = _stmt.getText(_columnIndexOfThumbnailUrl)
          }
          _item =
              HistoryEntry(_tmpWikiUrl,_tmpDisplayText,_tmpPageId,_tmpApiPath,_tmpTimestamp,_tmpSource,_tmpIsArchived,_tmpSnippet,_tmpThumbnailUrl)
          _result.add(_item)
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override suspend fun findEntryByUrl(wikiUrl: String): HistoryEntry? {
    val _sql: String = "SELECT * FROM history_entries WHERE page_wikiUrl = ?"
    return performSuspending(__db, true, false) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindText(_argIndex, wikiUrl)
        val _columnIndexOfWikiUrl: Int = getColumnIndexOrThrow(_stmt, "page_wikiUrl")
        val _columnIndexOfDisplayText: Int = getColumnIndexOrThrow(_stmt, "page_displayText")
        val _columnIndexOfPageId: Int = getColumnIndexOrThrow(_stmt, "page_pageId")
        val _columnIndexOfApiPath: Int = getColumnIndexOrThrow(_stmt, "page_apiPath")
        val _columnIndexOfTimestamp: Int = getColumnIndexOrThrow(_stmt, "timestamp")
        val _columnIndexOfSource: Int = getColumnIndexOrThrow(_stmt, "source")
        val _columnIndexOfIsArchived: Int = getColumnIndexOrThrow(_stmt, "is_archived")
        val _columnIndexOfSnippet: Int = getColumnIndexOrThrow(_stmt, "snippet")
        val _columnIndexOfThumbnailUrl: Int = getColumnIndexOrThrow(_stmt, "thumbnail_url")
        val _result: HistoryEntry?
        if (_stmt.step()) {
          val _tmpWikiUrl: String
          _tmpWikiUrl = _stmt.getText(_columnIndexOfWikiUrl)
          val _tmpDisplayText: String
          _tmpDisplayText = _stmt.getText(_columnIndexOfDisplayText)
          val _tmpPageId: Int?
          if (_stmt.isNull(_columnIndexOfPageId)) {
            _tmpPageId = null
          } else {
            _tmpPageId = _stmt.getLong(_columnIndexOfPageId).toInt()
          }
          val _tmpApiPath: String
          _tmpApiPath = _stmt.getText(_columnIndexOfApiPath)
          val _tmpTimestamp: Date
          val _tmp: Long?
          if (_stmt.isNull(_columnIndexOfTimestamp)) {
            _tmp = null
          } else {
            _tmp = _stmt.getLong(_columnIndexOfTimestamp)
          }
          val _tmp_1: Date? = DateConverter.fromTimestamp(_tmp)
          if (_tmp_1 == null) {
            error("Expected NON-NULL 'java.util.Date', but it was NULL.")
          } else {
            _tmpTimestamp = _tmp_1
          }
          val _tmpSource: Int
          _tmpSource = _stmt.getLong(_columnIndexOfSource).toInt()
          val _tmpIsArchived: Boolean
          val _tmp_2: Int
          _tmp_2 = _stmt.getLong(_columnIndexOfIsArchived).toInt()
          _tmpIsArchived = _tmp_2 != 0
          val _tmpSnippet: String?
          if (_stmt.isNull(_columnIndexOfSnippet)) {
            _tmpSnippet = null
          } else {
            _tmpSnippet = _stmt.getText(_columnIndexOfSnippet)
          }
          val _tmpThumbnailUrl: String?
          if (_stmt.isNull(_columnIndexOfThumbnailUrl)) {
            _tmpThumbnailUrl = null
          } else {
            _tmpThumbnailUrl = _stmt.getText(_columnIndexOfThumbnailUrl)
          }
          _result =
              HistoryEntry(_tmpWikiUrl,_tmpDisplayText,_tmpPageId,_tmpApiPath,_tmpTimestamp,_tmpSource,_tmpIsArchived,_tmpSnippet,_tmpThumbnailUrl)
        } else {
          _result = null
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override fun findEntriesByUrl(wikiUrl: String): Flow<List<HistoryEntry>> {
    val _sql: String =
        "SELECT * FROM history_entries WHERE page_wikiUrl = ? ORDER BY timestamp DESC"
    return createFlow(__db, false, arrayOf("history_entries")) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindText(_argIndex, wikiUrl)
        val _columnIndexOfWikiUrl: Int = getColumnIndexOrThrow(_stmt, "page_wikiUrl")
        val _columnIndexOfDisplayText: Int = getColumnIndexOrThrow(_stmt, "page_displayText")
        val _columnIndexOfPageId: Int = getColumnIndexOrThrow(_stmt, "page_pageId")
        val _columnIndexOfApiPath: Int = getColumnIndexOrThrow(_stmt, "page_apiPath")
        val _columnIndexOfTimestamp: Int = getColumnIndexOrThrow(_stmt, "timestamp")
        val _columnIndexOfSource: Int = getColumnIndexOrThrow(_stmt, "source")
        val _columnIndexOfIsArchived: Int = getColumnIndexOrThrow(_stmt, "is_archived")
        val _columnIndexOfSnippet: Int = getColumnIndexOrThrow(_stmt, "snippet")
        val _columnIndexOfThumbnailUrl: Int = getColumnIndexOrThrow(_stmt, "thumbnail_url")
        val _result: MutableList<HistoryEntry> = mutableListOf()
        while (_stmt.step()) {
          val _item: HistoryEntry
          val _tmpWikiUrl: String
          _tmpWikiUrl = _stmt.getText(_columnIndexOfWikiUrl)
          val _tmpDisplayText: String
          _tmpDisplayText = _stmt.getText(_columnIndexOfDisplayText)
          val _tmpPageId: Int?
          if (_stmt.isNull(_columnIndexOfPageId)) {
            _tmpPageId = null
          } else {
            _tmpPageId = _stmt.getLong(_columnIndexOfPageId).toInt()
          }
          val _tmpApiPath: String
          _tmpApiPath = _stmt.getText(_columnIndexOfApiPath)
          val _tmpTimestamp: Date
          val _tmp: Long?
          if (_stmt.isNull(_columnIndexOfTimestamp)) {
            _tmp = null
          } else {
            _tmp = _stmt.getLong(_columnIndexOfTimestamp)
          }
          val _tmp_1: Date? = DateConverter.fromTimestamp(_tmp)
          if (_tmp_1 == null) {
            error("Expected NON-NULL 'java.util.Date', but it was NULL.")
          } else {
            _tmpTimestamp = _tmp_1
          }
          val _tmpSource: Int
          _tmpSource = _stmt.getLong(_columnIndexOfSource).toInt()
          val _tmpIsArchived: Boolean
          val _tmp_2: Int
          _tmp_2 = _stmt.getLong(_columnIndexOfIsArchived).toInt()
          _tmpIsArchived = _tmp_2 != 0
          val _tmpSnippet: String?
          if (_stmt.isNull(_columnIndexOfSnippet)) {
            _tmpSnippet = null
          } else {
            _tmpSnippet = _stmt.getText(_columnIndexOfSnippet)
          }
          val _tmpThumbnailUrl: String?
          if (_stmt.isNull(_columnIndexOfThumbnailUrl)) {
            _tmpThumbnailUrl = null
          } else {
            _tmpThumbnailUrl = _stmt.getText(_columnIndexOfThumbnailUrl)
          }
          _item =
              HistoryEntry(_tmpWikiUrl,_tmpDisplayText,_tmpPageId,_tmpApiPath,_tmpTimestamp,_tmpSource,_tmpIsArchived,_tmpSnippet,_tmpThumbnailUrl)
          _result.add(_item)
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override suspend fun deleteEntryByUrl(wikiUrl: String) {
    val _sql: String = "DELETE FROM history_entries WHERE page_wikiUrl = ?"
    return performSuspending(__db, false, true) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindText(_argIndex, wikiUrl)
        _stmt.step()
      } finally {
        _stmt.close()
      }
    }
  }

  public override suspend fun deleteAllEntries() {
    val _sql: String = "DELETE FROM history_entries"
    return performSuspending(__db, false, true) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        _stmt.step()
      } finally {
        _stmt.close()
      }
    }
  }

  public companion object {
    public fun getRequiredConverters(): List<KClass<*>> = emptyList()
  }
}
