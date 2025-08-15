package com.bumptech.glide

import android.content.Context
import com.omiyawaki.osrswiki.OSRSWikiGlideModule
import kotlin.Boolean
import kotlin.Suppress

internal class GeneratedAppGlideModuleImpl(
  @Suppress("UNUSED_PARAMETER")
  context: Context,
) : GeneratedAppGlideModule() {
  private val appGlideModule: OSRSWikiGlideModule
  init {
    appGlideModule = OSRSWikiGlideModule()
  }

  public override fun registerComponents(
    context: Context,
    glide: Glide,
    registry: Registry,
  ) {
    appGlideModule.registerComponents(context, glide, registry)
  }

  public override fun applyOptions(context: Context, builder: GlideBuilder) {
    appGlideModule.applyOptions(context, builder)
  }

  public override fun isManifestParsingEnabled(): Boolean = false
}
