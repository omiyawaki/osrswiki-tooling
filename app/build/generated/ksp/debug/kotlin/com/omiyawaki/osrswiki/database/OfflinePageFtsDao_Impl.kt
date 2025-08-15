package com.omiyawaki.osrswiki.database

import androidx.room.EntityInsertAdapter
import androidx.room.RoomDatabase
import androidx.room.util.getColumnIndexOrThrow
import androidx.room.util.performSuspending
import androidx.sqlite.SQLiteStatement
import javax.`annotation`.processing.Generated
import kotlin.Int
import kotlin.String
import kotlin.Suppress
import kotlin.Unit
import kotlin.collections.List
import kotlin.collections.MutableList
import kotlin.collections.mutableListOf
import kotlin.reflect.KClass

@Generated(value = ["androidx.room.RoomProcessor"])
@Suppress(names = ["UNCHECKED_CAST", "DEPRECATION", "REDUNDANT_PROJECTION", "REMOVAL"])
public class OfflinePageFtsDao_Impl(
  __db: RoomDatabase,
) : OfflinePageFtsDao {
  private val __db: RoomDatabase

  private val __insertAdapterOfOfflinePageFts: EntityInsertAdapter<OfflinePageFts>
  init {
    this.__db = __db
    this.__insertAdapterOfOfflinePageFts = object : EntityInsertAdapter<OfflinePageFts>() {
      protected override fun createQuery(): String =
          "INSERT OR ABORT INTO `offline_page_fts` (`url`,`title`,`body`) VALUES (?,?,?)"

      protected override fun bind(statement: SQLiteStatement, entity: OfflinePageFts) {
        statement.bindText(1, entity.url)
        statement.bindText(2, entity.title)
        statement.bindText(3, entity.body)
      }
    }
  }

  public override suspend fun insertPageContent(item: OfflinePageFts): Unit =
      performSuspending(__db, false, true) { _connection ->
    __insertAdapterOfOfflinePageFts.insert(_connection, item)
  }

  public override suspend fun searchAll(query: String): List<OfflinePageFts> {
    val _sql: String = "SELECT * FROM offline_page_fts WHERE offline_page_fts MATCH ?"
    return performSuspending(__db, true, false) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindText(_argIndex, query)
        val _columnIndexOfUrl: Int = getColumnIndexOrThrow(_stmt, "url")
        val _columnIndexOfTitle: Int = getColumnIndexOrThrow(_stmt, "title")
        val _columnIndexOfBody: Int = getColumnIndexOrThrow(_stmt, "body")
        val _result: MutableList<OfflinePageFts> = mutableListOf()
        while (_stmt.step()) {
          val _item: OfflinePageFts
          val _tmpUrl: String
          _tmpUrl = _stmt.getText(_columnIndexOfUrl)
          val _tmpTitle: String
          _tmpTitle = _stmt.getText(_columnIndexOfTitle)
          val _tmpBody: String
          _tmpBody = _stmt.getText(_columnIndexOfBody)
          _item = OfflinePageFts(_tmpUrl,_tmpTitle,_tmpBody)
          _result.add(_item)
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override suspend fun getAll(): List<OfflinePageFts> {
    val _sql: String = "SELECT * FROM offline_page_fts"
    return performSuspending(__db, true, false) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        val _columnIndexOfUrl: Int = getColumnIndexOrThrow(_stmt, "url")
        val _columnIndexOfTitle: Int = getColumnIndexOrThrow(_stmt, "title")
        val _columnIndexOfBody: Int = getColumnIndexOrThrow(_stmt, "body")
        val _result: MutableList<OfflinePageFts> = mutableListOf()
        while (_stmt.step()) {
          val _item: OfflinePageFts
          val _tmpUrl: String
          _tmpUrl = _stmt.getText(_columnIndexOfUrl)
          val _tmpTitle: String
          _tmpTitle = _stmt.getText(_columnIndexOfTitle)
          val _tmpBody: String
          _tmpBody = _stmt.getText(_columnIndexOfBody)
          _item = OfflinePageFts(_tmpUrl,_tmpTitle,_tmpBody)
          _result.add(_item)
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override suspend fun deletePageContentByUrl(url: String) {
    val _sql: String = "DELETE FROM offline_page_fts WHERE url = ?"
    return performSuspending(__db, false, true) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindText(_argIndex, url)
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
