package com.omiyawaki.osrswiki.database

import androidx.room.InvalidationTracker
import androidx.room.RoomOpenDelegate
import androidx.room.migration.AutoMigrationSpec
import androidx.room.migration.Migration
import androidx.room.util.FtsTableInfo
import androidx.room.util.TableInfo
import androidx.room.util.dropFtsSyncTriggers
import androidx.sqlite.SQLiteConnection
import androidx.sqlite.execSQL
import com.omiyawaki.osrswiki.history.db.HistoryEntryDao
import com.omiyawaki.osrswiki.history.db.HistoryEntryDao_Impl
import com.omiyawaki.osrswiki.offline.db.OfflineObjectDao
import com.omiyawaki.osrswiki.offline.db.OfflineObjectDao_Impl
import com.omiyawaki.osrswiki.readinglist.db.ReadingListDao
import com.omiyawaki.osrswiki.readinglist.db.ReadingListDao_Impl
import com.omiyawaki.osrswiki.readinglist.db.ReadingListPageDao
import com.omiyawaki.osrswiki.readinglist.db.ReadingListPageDao_Impl
import com.omiyawaki.osrswiki.search.db.RecentSearchDao
import com.omiyawaki.osrswiki.search.db.RecentSearchDao_Impl
import javax.`annotation`.processing.Generated
import kotlin.Lazy
import kotlin.String
import kotlin.Suppress
import kotlin.collections.List
import kotlin.collections.Map
import kotlin.collections.MutableList
import kotlin.collections.MutableMap
import kotlin.collections.MutableSet
import kotlin.collections.Set
import kotlin.collections.mutableListOf
import kotlin.collections.mutableMapOf
import kotlin.collections.mutableSetOf
import kotlin.reflect.KClass
import androidx.room.util.FtsTableInfo.Companion.read as ftsTableInfoRead
import androidx.room.util.TableInfo.Companion.read as tableInfoRead

@Generated(value = ["androidx.room.RoomProcessor"])
@Suppress(names = ["UNCHECKED_CAST", "DEPRECATION", "REDUNDANT_PROJECTION", "REMOVAL"])
public class AppDatabase_Impl : AppDatabase() {
  private val _articleMetaDao: Lazy<ArticleMetaDao> = lazy {
    ArticleMetaDao_Impl(this)
  }

  private val _readingListDao: Lazy<ReadingListDao> = lazy {
    ReadingListDao_Impl(this)
  }

  private val _readingListPageDao: Lazy<ReadingListPageDao> = lazy {
    ReadingListPageDao_Impl(this)
  }

  private val _offlineObjectDao: Lazy<OfflineObjectDao> = lazy {
    OfflineObjectDao_Impl(this)
  }

  private val _offlinePageFtsDao: Lazy<OfflinePageFtsDao> = lazy {
    OfflinePageFtsDao_Impl(this)
  }

  private val _historyEntryDao: Lazy<HistoryEntryDao> = lazy {
    HistoryEntryDao_Impl(this)
  }

  private val _recentSearchDao: Lazy<RecentSearchDao> = lazy {
    RecentSearchDao_Impl(this)
  }

  protected override fun createOpenDelegate(): RoomOpenDelegate {
    val _openDelegate: RoomOpenDelegate = object : RoomOpenDelegate(16,
        "d99e22947c8015b4f466cc5e8e176f47", "b660afbfdd96b79e82d41d047219cbe9") {
      public override fun createAllTables(connection: SQLiteConnection) {
        connection.execSQL("CREATE TABLE IF NOT EXISTS `article_meta` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `pageId` INTEGER NOT NULL, `title` TEXT NOT NULL, `wikiUrl` TEXT NOT NULL, `localFilePath` TEXT NOT NULL, `lastFetchedTimestamp` INTEGER NOT NULL, `revisionId` INTEGER, `categories` TEXT)")
        connection.execSQL("CREATE INDEX IF NOT EXISTS `index_article_meta_title` ON `article_meta` (`title`)")
        connection.execSQL("CREATE TABLE IF NOT EXISTS `ReadingList` (`title` TEXT NOT NULL, `description` TEXT, `mtime` INTEGER NOT NULL, `atime` INTEGER NOT NULL, `id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `isDefault` INTEGER NOT NULL)")
        connection.execSQL("CREATE TABLE IF NOT EXISTS `ReadingListPage` (`wiki` TEXT NOT NULL, `namespace` TEXT NOT NULL, `displayTitle` TEXT NOT NULL, `apiTitle` TEXT NOT NULL, `description` TEXT, `thumbUrl` TEXT, `listId` INTEGER NOT NULL, `id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `mtime` INTEGER NOT NULL, `atime` INTEGER NOT NULL, `offline` INTEGER NOT NULL, `status` INTEGER NOT NULL, `sizeBytes` INTEGER NOT NULL, `lang` TEXT NOT NULL, `revId` INTEGER NOT NULL, `remoteId` INTEGER NOT NULL, `mediaWikiPageId` INTEGER, `downloadProgress` INTEGER NOT NULL)")
        connection.execSQL("CREATE TABLE IF NOT EXISTS `offline_objects` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `url` TEXT NOT NULL COLLATE NOCASE, `lang` TEXT NOT NULL, `path` TEXT NOT NULL, `status` INTEGER NOT NULL, `usedByStr` TEXT NOT NULL, `saveType` TEXT NOT NULL)")
        connection.execSQL("CREATE UNIQUE INDEX IF NOT EXISTS `index_offline_objects_url_lang` ON `offline_objects` (`url`, `lang`)")
        connection.execSQL("CREATE VIRTUAL TABLE IF NOT EXISTS `offline_page_fts` USING FTS4(`url` TEXT NOT NULL, `title` TEXT NOT NULL, `body` TEXT NOT NULL)")
        connection.execSQL("CREATE TABLE IF NOT EXISTS `history_entries` (`page_wikiUrl` TEXT NOT NULL, `page_displayText` TEXT NOT NULL, `page_pageId` INTEGER, `page_apiPath` TEXT NOT NULL, `timestamp` INTEGER NOT NULL, `source` INTEGER NOT NULL, `is_archived` INTEGER NOT NULL DEFAULT 0, `snippet` TEXT, `thumbnail_url` TEXT, PRIMARY KEY(`page_wikiUrl`))")
        connection.execSQL("CREATE TABLE IF NOT EXISTS `recent_searches` (`query` TEXT NOT NULL, `timestamp` INTEGER NOT NULL, PRIMARY KEY(`query`))")
        connection.execSQL("CREATE TABLE IF NOT EXISTS room_master_table (id INTEGER PRIMARY KEY,identity_hash TEXT)")
        connection.execSQL("INSERT OR REPLACE INTO room_master_table (id,identity_hash) VALUES(42, 'd99e22947c8015b4f466cc5e8e176f47')")
      }

      public override fun dropAllTables(connection: SQLiteConnection) {
        connection.execSQL("DROP TABLE IF EXISTS `article_meta`")
        connection.execSQL("DROP TABLE IF EXISTS `ReadingList`")
        connection.execSQL("DROP TABLE IF EXISTS `ReadingListPage`")
        connection.execSQL("DROP TABLE IF EXISTS `offline_objects`")
        connection.execSQL("DROP TABLE IF EXISTS `offline_page_fts`")
        connection.execSQL("DROP TABLE IF EXISTS `history_entries`")
        connection.execSQL("DROP TABLE IF EXISTS `recent_searches`")
      }

      public override fun onCreate(connection: SQLiteConnection) {
      }

      public override fun onOpen(connection: SQLiteConnection) {
        internalInitInvalidationTracker(connection)
      }

      public override fun onPreMigrate(connection: SQLiteConnection) {
        dropFtsSyncTriggers(connection)
      }

      public override fun onPostMigrate(connection: SQLiteConnection) {
      }

      public override fun onValidateSchema(connection: SQLiteConnection):
          RoomOpenDelegate.ValidationResult {
        val _columnsArticleMeta: MutableMap<String, TableInfo.Column> = mutableMapOf()
        _columnsArticleMeta.put("id", TableInfo.Column("id", "INTEGER", true, 1, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsArticleMeta.put("pageId", TableInfo.Column("pageId", "INTEGER", true, 0, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsArticleMeta.put("title", TableInfo.Column("title", "TEXT", true, 0, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsArticleMeta.put("wikiUrl", TableInfo.Column("wikiUrl", "TEXT", true, 0, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsArticleMeta.put("localFilePath", TableInfo.Column("localFilePath", "TEXT", true, 0,
            null, TableInfo.CREATED_FROM_ENTITY))
        _columnsArticleMeta.put("lastFetchedTimestamp", TableInfo.Column("lastFetchedTimestamp",
            "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY))
        _columnsArticleMeta.put("revisionId", TableInfo.Column("revisionId", "INTEGER", false, 0,
            null, TableInfo.CREATED_FROM_ENTITY))
        _columnsArticleMeta.put("categories", TableInfo.Column("categories", "TEXT", false, 0, null,
            TableInfo.CREATED_FROM_ENTITY))
        val _foreignKeysArticleMeta: MutableSet<TableInfo.ForeignKey> = mutableSetOf()
        val _indicesArticleMeta: MutableSet<TableInfo.Index> = mutableSetOf()
        _indicesArticleMeta.add(TableInfo.Index("index_article_meta_title", false, listOf("title"),
            listOf("ASC")))
        val _infoArticleMeta: TableInfo = TableInfo("article_meta", _columnsArticleMeta,
            _foreignKeysArticleMeta, _indicesArticleMeta)
        val _existingArticleMeta: TableInfo = tableInfoRead(connection, "article_meta")
        if (!_infoArticleMeta.equals(_existingArticleMeta)) {
          return RoomOpenDelegate.ValidationResult(false, """
              |article_meta(com.omiyawaki.osrswiki.database.ArticleMetaEntity).
              | Expected:
              |""".trimMargin() + _infoArticleMeta + """
              |
              | Found:
              |""".trimMargin() + _existingArticleMeta)
        }
        val _columnsReadingList: MutableMap<String, TableInfo.Column> = mutableMapOf()
        _columnsReadingList.put("title", TableInfo.Column("title", "TEXT", true, 0, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsReadingList.put("description", TableInfo.Column("description", "TEXT", false, 0,
            null, TableInfo.CREATED_FROM_ENTITY))
        _columnsReadingList.put("mtime", TableInfo.Column("mtime", "INTEGER", true, 0, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsReadingList.put("atime", TableInfo.Column("atime", "INTEGER", true, 0, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsReadingList.put("id", TableInfo.Column("id", "INTEGER", true, 1, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsReadingList.put("isDefault", TableInfo.Column("isDefault", "INTEGER", true, 0, null,
            TableInfo.CREATED_FROM_ENTITY))
        val _foreignKeysReadingList: MutableSet<TableInfo.ForeignKey> = mutableSetOf()
        val _indicesReadingList: MutableSet<TableInfo.Index> = mutableSetOf()
        val _infoReadingList: TableInfo = TableInfo("ReadingList", _columnsReadingList,
            _foreignKeysReadingList, _indicesReadingList)
        val _existingReadingList: TableInfo = tableInfoRead(connection, "ReadingList")
        if (!_infoReadingList.equals(_existingReadingList)) {
          return RoomOpenDelegate.ValidationResult(false, """
              |ReadingList(com.omiyawaki.osrswiki.readinglist.database.ReadingList).
              | Expected:
              |""".trimMargin() + _infoReadingList + """
              |
              | Found:
              |""".trimMargin() + _existingReadingList)
        }
        val _columnsReadingListPage: MutableMap<String, TableInfo.Column> = mutableMapOf()
        _columnsReadingListPage.put("wiki", TableInfo.Column("wiki", "TEXT", true, 0, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsReadingListPage.put("namespace", TableInfo.Column("namespace", "TEXT", true, 0,
            null, TableInfo.CREATED_FROM_ENTITY))
        _columnsReadingListPage.put("displayTitle", TableInfo.Column("displayTitle", "TEXT", true,
            0, null, TableInfo.CREATED_FROM_ENTITY))
        _columnsReadingListPage.put("apiTitle", TableInfo.Column("apiTitle", "TEXT", true, 0, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsReadingListPage.put("description", TableInfo.Column("description", "TEXT", false, 0,
            null, TableInfo.CREATED_FROM_ENTITY))
        _columnsReadingListPage.put("thumbUrl", TableInfo.Column("thumbUrl", "TEXT", false, 0, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsReadingListPage.put("listId", TableInfo.Column("listId", "INTEGER", true, 0, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsReadingListPage.put("id", TableInfo.Column("id", "INTEGER", true, 1, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsReadingListPage.put("mtime", TableInfo.Column("mtime", "INTEGER", true, 0, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsReadingListPage.put("atime", TableInfo.Column("atime", "INTEGER", true, 0, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsReadingListPage.put("offline", TableInfo.Column("offline", "INTEGER", true, 0, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsReadingListPage.put("status", TableInfo.Column("status", "INTEGER", true, 0, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsReadingListPage.put("sizeBytes", TableInfo.Column("sizeBytes", "INTEGER", true, 0,
            null, TableInfo.CREATED_FROM_ENTITY))
        _columnsReadingListPage.put("lang", TableInfo.Column("lang", "TEXT", true, 0, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsReadingListPage.put("revId", TableInfo.Column("revId", "INTEGER", true, 0, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsReadingListPage.put("remoteId", TableInfo.Column("remoteId", "INTEGER", true, 0,
            null, TableInfo.CREATED_FROM_ENTITY))
        _columnsReadingListPage.put("mediaWikiPageId", TableInfo.Column("mediaWikiPageId",
            "INTEGER", false, 0, null, TableInfo.CREATED_FROM_ENTITY))
        _columnsReadingListPage.put("downloadProgress", TableInfo.Column("downloadProgress",
            "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY))
        val _foreignKeysReadingListPage: MutableSet<TableInfo.ForeignKey> = mutableSetOf()
        val _indicesReadingListPage: MutableSet<TableInfo.Index> = mutableSetOf()
        val _infoReadingListPage: TableInfo = TableInfo("ReadingListPage", _columnsReadingListPage,
            _foreignKeysReadingListPage, _indicesReadingListPage)
        val _existingReadingListPage: TableInfo = tableInfoRead(connection, "ReadingListPage")
        if (!_infoReadingListPage.equals(_existingReadingListPage)) {
          return RoomOpenDelegate.ValidationResult(false, """
              |ReadingListPage(com.omiyawaki.osrswiki.readinglist.database.ReadingListPage).
              | Expected:
              |""".trimMargin() + _infoReadingListPage + """
              |
              | Found:
              |""".trimMargin() + _existingReadingListPage)
        }
        val _columnsOfflineObjects: MutableMap<String, TableInfo.Column> = mutableMapOf()
        _columnsOfflineObjects.put("id", TableInfo.Column("id", "INTEGER", true, 1, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsOfflineObjects.put("url", TableInfo.Column("url", "TEXT", true, 0, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsOfflineObjects.put("lang", TableInfo.Column("lang", "TEXT", true, 0, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsOfflineObjects.put("path", TableInfo.Column("path", "TEXT", true, 0, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsOfflineObjects.put("status", TableInfo.Column("status", "INTEGER", true, 0, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsOfflineObjects.put("usedByStr", TableInfo.Column("usedByStr", "TEXT", true, 0, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsOfflineObjects.put("saveType", TableInfo.Column("saveType", "TEXT", true, 0, null,
            TableInfo.CREATED_FROM_ENTITY))
        val _foreignKeysOfflineObjects: MutableSet<TableInfo.ForeignKey> = mutableSetOf()
        val _indicesOfflineObjects: MutableSet<TableInfo.Index> = mutableSetOf()
        _indicesOfflineObjects.add(TableInfo.Index("index_offline_objects_url_lang", true,
            listOf("url", "lang"), listOf("ASC", "ASC")))
        val _infoOfflineObjects: TableInfo = TableInfo("offline_objects", _columnsOfflineObjects,
            _foreignKeysOfflineObjects, _indicesOfflineObjects)
        val _existingOfflineObjects: TableInfo = tableInfoRead(connection, "offline_objects")
        if (!_infoOfflineObjects.equals(_existingOfflineObjects)) {
          return RoomOpenDelegate.ValidationResult(false, """
              |offline_objects(com.omiyawaki.osrswiki.offline.db.OfflineObject).
              | Expected:
              |""".trimMargin() + _infoOfflineObjects + """
              |
              | Found:
              |""".trimMargin() + _existingOfflineObjects)
        }
        val _columnsOfflinePageFts: MutableSet<String> = mutableSetOf()
        _columnsOfflinePageFts.add("url")
        _columnsOfflinePageFts.add("title")
        _columnsOfflinePageFts.add("body")
        val _infoOfflinePageFts: FtsTableInfo = FtsTableInfo("offline_page_fts",
            _columnsOfflinePageFts,
            "CREATE VIRTUAL TABLE IF NOT EXISTS `offline_page_fts` USING FTS4(`url` TEXT NOT NULL, `title` TEXT NOT NULL, `body` TEXT NOT NULL)")
        val _existingOfflinePageFts: FtsTableInfo = ftsTableInfoRead(connection, "offline_page_fts")
        if (!_infoOfflinePageFts.equals(_existingOfflinePageFts)) {
          return RoomOpenDelegate.ValidationResult(false, """
              |offline_page_fts(com.omiyawaki.osrswiki.database.OfflinePageFts).
              | Expected:
              |""".trimMargin() + _infoOfflinePageFts + """
              |
              | Found:
              |""".trimMargin() + _existingOfflinePageFts)
        }
        val _columnsHistoryEntries: MutableMap<String, TableInfo.Column> = mutableMapOf()
        _columnsHistoryEntries.put("page_wikiUrl", TableInfo.Column("page_wikiUrl", "TEXT", true, 1,
            null, TableInfo.CREATED_FROM_ENTITY))
        _columnsHistoryEntries.put("page_displayText", TableInfo.Column("page_displayText", "TEXT",
            true, 0, null, TableInfo.CREATED_FROM_ENTITY))
        _columnsHistoryEntries.put("page_pageId", TableInfo.Column("page_pageId", "INTEGER", false,
            0, null, TableInfo.CREATED_FROM_ENTITY))
        _columnsHistoryEntries.put("page_apiPath", TableInfo.Column("page_apiPath", "TEXT", true, 0,
            null, TableInfo.CREATED_FROM_ENTITY))
        _columnsHistoryEntries.put("timestamp", TableInfo.Column("timestamp", "INTEGER", true, 0,
            null, TableInfo.CREATED_FROM_ENTITY))
        _columnsHistoryEntries.put("source", TableInfo.Column("source", "INTEGER", true, 0, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsHistoryEntries.put("is_archived", TableInfo.Column("is_archived", "INTEGER", true,
            0, "0", TableInfo.CREATED_FROM_ENTITY))
        _columnsHistoryEntries.put("snippet", TableInfo.Column("snippet", "TEXT", false, 0, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsHistoryEntries.put("thumbnail_url", TableInfo.Column("thumbnail_url", "TEXT", false,
            0, null, TableInfo.CREATED_FROM_ENTITY))
        val _foreignKeysHistoryEntries: MutableSet<TableInfo.ForeignKey> = mutableSetOf()
        val _indicesHistoryEntries: MutableSet<TableInfo.Index> = mutableSetOf()
        val _infoHistoryEntries: TableInfo = TableInfo("history_entries", _columnsHistoryEntries,
            _foreignKeysHistoryEntries, _indicesHistoryEntries)
        val _existingHistoryEntries: TableInfo = tableInfoRead(connection, "history_entries")
        if (!_infoHistoryEntries.equals(_existingHistoryEntries)) {
          return RoomOpenDelegate.ValidationResult(false, """
              |history_entries(com.omiyawaki.osrswiki.history.db.HistoryEntry).
              | Expected:
              |""".trimMargin() + _infoHistoryEntries + """
              |
              | Found:
              |""".trimMargin() + _existingHistoryEntries)
        }
        val _columnsRecentSearches: MutableMap<String, TableInfo.Column> = mutableMapOf()
        _columnsRecentSearches.put("query", TableInfo.Column("query", "TEXT", true, 1, null,
            TableInfo.CREATED_FROM_ENTITY))
        _columnsRecentSearches.put("timestamp", TableInfo.Column("timestamp", "INTEGER", true, 0,
            null, TableInfo.CREATED_FROM_ENTITY))
        val _foreignKeysRecentSearches: MutableSet<TableInfo.ForeignKey> = mutableSetOf()
        val _indicesRecentSearches: MutableSet<TableInfo.Index> = mutableSetOf()
        val _infoRecentSearches: TableInfo = TableInfo("recent_searches", _columnsRecentSearches,
            _foreignKeysRecentSearches, _indicesRecentSearches)
        val _existingRecentSearches: TableInfo = tableInfoRead(connection, "recent_searches")
        if (!_infoRecentSearches.equals(_existingRecentSearches)) {
          return RoomOpenDelegate.ValidationResult(false, """
              |recent_searches(com.omiyawaki.osrswiki.search.db.RecentSearch).
              | Expected:
              |""".trimMargin() + _infoRecentSearches + """
              |
              | Found:
              |""".trimMargin() + _existingRecentSearches)
        }
        return RoomOpenDelegate.ValidationResult(true, null)
      }
    }
    return _openDelegate
  }

  protected override fun createInvalidationTracker(): InvalidationTracker {
    val _shadowTablesMap: MutableMap<String, String> = mutableMapOf()
    _shadowTablesMap.put("offline_page_fts", "offline_page_fts_content")
    val _viewTables: MutableMap<String, Set<String>> = mutableMapOf()
    return InvalidationTracker(this, _shadowTablesMap, _viewTables, "article_meta", "ReadingList",
        "ReadingListPage", "offline_objects", "offline_page_fts", "history_entries",
        "recent_searches")
  }

  public override fun clearAllTables() {
    super.performClear(false, "article_meta", "ReadingList", "ReadingListPage", "offline_objects",
        "offline_page_fts", "history_entries", "recent_searches")
  }

  protected override fun getRequiredTypeConverterClasses(): Map<KClass<*>, List<KClass<*>>> {
    val _typeConvertersMap: MutableMap<KClass<*>, List<KClass<*>>> = mutableMapOf()
    _typeConvertersMap.put(ArticleMetaDao::class, ArticleMetaDao_Impl.getRequiredConverters())
    _typeConvertersMap.put(ReadingListDao::class, ReadingListDao_Impl.getRequiredConverters())
    _typeConvertersMap.put(ReadingListPageDao::class,
        ReadingListPageDao_Impl.getRequiredConverters())
    _typeConvertersMap.put(OfflineObjectDao::class, OfflineObjectDao_Impl.getRequiredConverters())
    _typeConvertersMap.put(OfflinePageFtsDao::class, OfflinePageFtsDao_Impl.getRequiredConverters())
    _typeConvertersMap.put(HistoryEntryDao::class, HistoryEntryDao_Impl.getRequiredConverters())
    _typeConvertersMap.put(RecentSearchDao::class, RecentSearchDao_Impl.getRequiredConverters())
    return _typeConvertersMap
  }

  public override fun getRequiredAutoMigrationSpecClasses(): Set<KClass<out AutoMigrationSpec>> {
    val _autoMigrationSpecsSet: MutableSet<KClass<out AutoMigrationSpec>> = mutableSetOf()
    return _autoMigrationSpecsSet
  }

  public override
      fun createAutoMigrations(autoMigrationSpecs: Map<KClass<out AutoMigrationSpec>, AutoMigrationSpec>):
      List<Migration> {
    val _autoMigrations: MutableList<Migration> = mutableListOf()
    return _autoMigrations
  }

  public override fun articleMetaDao(): ArticleMetaDao = _articleMetaDao.value

  public override fun readingListDao(): ReadingListDao = _readingListDao.value

  public override fun readingListPageDao(): ReadingListPageDao = _readingListPageDao.value

  public override fun offlineObjectDao(): OfflineObjectDao = _offlineObjectDao.value

  public override fun offlinePageFtsDao(): OfflinePageFtsDao = _offlinePageFtsDao.value

  public override fun historyEntryDao(): HistoryEntryDao = _historyEntryDao.value

  public override fun recentSearchDao(): RecentSearchDao = _recentSearchDao.value
}
