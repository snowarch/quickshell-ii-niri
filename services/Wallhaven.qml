pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import qs.services
import QtQuick

/**
 * Simple wallpaper search service for wallhaven.cc
 * Reuses BooruResponseData so it can be rendered with existing Booru UI components.
 */
Singleton {
    id: root

    property Component wallhavenResponseComponent: BooruResponseData {}

    signal responseFinished()

    property string failMessage: Translation.tr("That didn't work. Tips:\n- Check your query and NSFW settings\n- Make sure your Wallhaven API key is set if you want NSFW")
    property var responses: []
    property int runningRequests: 0

    // Basic settings
    readonly property string apiBase: "https://wallhaven.cc/api/v1"
    readonly property string apiSearchEndpoint: apiBase + "/search"

    // Config-driven options
    property string apiKey: Config.options?.sidebar?.wallhaven?.apiKey ?? ""
    property int defaultLimit: Config.options?.sidebar?.wallhaven?.limit ?? 24
    // Reuse global NSFW toggle used by Anime boorus for now
    property bool allowNsfw: Persistent.states.booru.allowNsfw

    function clearResponses() {
        responses = []
    }

    function _buildSearchUrl(tags, nsfw, limit, page) {
        var url = apiSearchEndpoint
        var params = []

        var q = (tags || []).join(" ").trim()
        if (q.length > 0)
            params.push("q=" + encodeURIComponent(q))

        page = page || 1
        params.push("page=" + page)

        var effLimit = (limit && limit > 0) ? limit : defaultLimit
        params.push("per_page=" + effLimit)

        // categories: general, anime, people -> 111 = all
        params.push("categories=111")

        // purity: 100 = sfw, 110 = sfw+sketchy, 111 = sfw+sketchy+nsfw
        var purity = "100" // default: SFW only
        if (nsfw && apiKey && apiKey.length > 0) {
            purity = "111"
        }
        params.push("purity=" + purity)

        // sort newest first
        params.push("sorting=date_added")
        params.push("order=desc")

        if (apiKey && apiKey.length > 0) {
            params.push("apikey=" + encodeURIComponent(apiKey))
        }

        return url + "?" + params.join("&")
    }

    function makeRequest(tags, nsfw, limit, page) {
        // nsfw/limit/page kept for API parity with Booru.makeRequest
        if (nsfw === undefined)
            nsfw = allowNsfw
        var url = _buildSearchUrl(tags, nsfw, limit, page)
        console.log("[Wallhaven] Making request to", url)

        var newResponse = wallhavenResponseComponent.createObject(null, {
            "provider": "wallhaven",
            "tags": tags,
            "page": page || 1,
            "images": [],
            "message": ""
        })

        var xhr = new XMLHttpRequest()
        xhr.open("GET", url)
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return

            function finish() {
                runningRequests = Math.max(0, runningRequests - 1)
                responses = [...responses, newResponse]
                root.responseFinished()
            }

            if (xhr.status === 200) {
                try {
                    var payload = JSON.parse(xhr.responseText)
                    var list = payload.data || []
                    var images = list.map(function(item) {
                        var path = item.path || ""
                        var thumbs = item.thumbs || {}
                        var preview = thumbs.small || thumbs.large || path
                        var sample = thumbs.large || path
                        var ratio = 1.0
                        if (item.ratio) {
                            ratio = parseFloat(item.ratio)
                        } else if (item.dimension_x && item.dimension_y) {
                            ratio = item.dimension_x / item.dimension_y
                        }
                        var tagsJoined = ""
                        if (item.tags && item.tags.length > 0) {
                            tagsJoined = item.tags.map(function(t) { return t.name; }).join(" ")
                        }
                        var purity = item.purity || "sfw"
                        var isNsfw = purity !== "sfw"
                        var fileExt = ""
                        if (path && path.indexOf(".") !== -1) {
                            fileExt = path.split(".").pop()
                        }
                        return {
                            "id": item.id,
                            "width": item.dimension_x,
                            "height": item.dimension_y,
                            "aspect_ratio": ratio,
                            "tags": tagsJoined,
                            "rating": isNsfw ? "e" : "s",
                            "is_nsfw": isNsfw,
                            "md5": Qt.md5(path || item.id),
                            "preview_url": preview,
                            "sample_url": sample,
                            "file_url": path,
                            "file_ext": fileExt,
                            "source": item.url
                        }
                    })
                    newResponse.images = images
                    newResponse.message = images.length > 0 ? "" : failMessage
                } catch (e) {
                    console.log("[Wallhaven] Failed to parse response:", e)
                    newResponse.message = failMessage
                } finally {
                    finish()
                }
            } else {
                console.log("[Wallhaven] Request failed with status:", xhr.status)
                newResponse.message = failMessage
                finish()
            }
        }

        try {
            runningRequests += 1
            xhr.send()
        } catch (e) {
            console.log("[Wallhaven] Error sending request:", e)
            runningRequests = Math.max(0, runningRequests - 1)
            newResponse.message = failMessage
            responses = [...responses, newResponse]
            root.responseFinished()
        }
    }
}
