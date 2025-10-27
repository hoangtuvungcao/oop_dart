'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "12eb68060795c2566ce915e53df4a540",
"assets/AssetManifest.bin.json": "1b7ec203e00d7fdb9f7279bd4fbf576e",
"assets/AssetManifest.json": "1261ec0b94eb936a183249cf97db33dc",
"assets/assets/audio/%25E6%2598%25AF%25E5%25BF%2583%25E5%258A%25A8%25E5%2595%258A%2520-%2520%25E5%258E%259F%25E6%259D%25A5%25E6%2598%25AF%25E8%2590%259D%25E5%258D%259C%25E4%25B8%25AB.mp3": "9285315ac80305be3c9dee90c2fddc05",
"assets/assets/audio/flip.mp3": "beee813460e6c0fe6e68f612ac30181c",
"assets/assets/audio/game_play.mp3": "3e3bf387f1144c2335a62f3b91d7de17",
"assets/assets/audio/lose.mp3": "25a31863ebbf54ea2ec84bcf20326f2c",
"assets/assets/audio/loss.mp3": "1786331f36290dea570c5df2bf94a56e",
"assets/assets/audio/Thirteen.mp3": "6cabc2e5bfa870c3bb55f519e56d18df",
"assets/assets/audio/w.mp3": "de8083780629a56b58ce7ab8b117542d",
"assets/assets/audio/win.mp3": "3fe88da02225c7322899e2eb42cd4ab7",
"assets/assets/fonts/KFOmCnqEu92Fr1Me4GZLCzYlKw.woff2": "e507bd45228483ae2f864d36f26bb43e",
"assets/assets/levels/1.jpg": "86065877fd4e79a50a3d012e0621dc10",
"assets/assets/levels/10.jpg": "8f46f594ff9f3357bbc8e765a0fddfa3",
"assets/assets/levels/11.jpg": "7d05f84507f10a6e8d605cab2d94c4a9",
"assets/assets/levels/12.jpg": "365cc1734a2363e1af40642d287c9af9",
"assets/assets/levels/13.jpg": "e3fd06b08d95cfa3c9b1c63d20f95a63",
"assets/assets/levels/14.jpg": "b55fa393e6e7ab2f23ce0f9be4b1e232",
"assets/assets/levels/15.jpg": "fb844b98fc91e229377586a795005827",
"assets/assets/levels/16.jpg": "1256e8a41bf686f4c67910c3b5cd518c",
"assets/assets/levels/17.jpg": "039a99ad42d15378fd40b083117baf6c",
"assets/assets/levels/18.jpg": "1b1b52c8b6ba32cab9b3aea3a6b514f5",
"assets/assets/levels/19.jpg": "6387b56488ceec91470d16c3d04aba8b",
"assets/assets/levels/2.jpg": "f23a724bf27a405dc875c74ab4325532",
"assets/assets/levels/20.jpg": "8c84b6c93b47f479f22b29ffb01668f9",
"assets/assets/levels/21.jpg": "83ef0868c72f80449e7f3eac7e588a8c",
"assets/assets/levels/22.jpg": "9af39cf70b7bb01d9db1334db34c70af",
"assets/assets/levels/23.jpg": "b434b55dbf9ec603c95c0a56948a695a",
"assets/assets/levels/3.jpg": "6852c8bbb3b282dab35dcbb980b01242",
"assets/assets/levels/4.jpg": "4bbfea2355ef24a05c2ae29c12edfa37",
"assets/assets/levels/5.jpg": "02b16fea275a1be159fbdc7277d605d0",
"assets/assets/levels/6.jpg": "4cd6098581ca8e3c74c9ac58c5cadd0c",
"assets/assets/levels/7.jpg": "31c23091d148864797b58da887cf8dfb",
"assets/assets/levels/8.jpg": "76972977bdeedebb3b0c7ef0491f2f2a",
"assets/assets/levels/9.jpg": "ca57772215e49d79e3df77b5646b6043",
"assets/assets/levels/back.png": "0c0ed9538990c079ee2bff946574446b",
"assets/assets/levels/bom.png": "bfda18218d114ae6f8b9e35d155d22a0",
"assets/assets/levels/c.py": "d4153d436d18014aa16e54e21428195d",
"assets/assets/photo/icon.ico": "724c3c62b84c41086b50196c7991caf2",
"assets/assets/photo/icon.png": "dec67de7e5bd3c4e30c4605ca388553d",
"assets/assets/photo/modelGIF1.gif": "8d8a199efbe994d8046acc30cd58737c",
"assets/assets/photo/nenapp1.gif": "0fda9e963822e996eb669eced4a643b4",
"assets/assets/photo/nenapp2.gif": "87ee686ee81f2d80c84c6b8712cfc2a7",
"assets/assets/photo/nenapp20.gif": "8bd2059c1412e77b1c740a9e106f2fd1",
"assets/FontManifest.json": "503b15a825c31537d74c42a25a3e62cf",
"assets/fonts/MaterialIcons-Regular.otf": "623575129d6050c97b21584bea3657a3",
"assets/NOTICES": "241bb5a7b89829f982829ca8999d3073",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"favicon.png": "7a4aa17af58ac6a4dbea7f85b558dce0",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "2795c6f10320259ebe2363ef1d4a5675",
"icons/app_icon.png": "7a4aa17af58ac6a4dbea7f85b558dce0",
"index.html": "32e6db075cd6ff211909a149b4f8dbd7",
"/": "32e6db075cd6ff211909a149b4f8dbd7",
"main.dart.js": "891e0b9f89596e767787d70b31f0bc0e",
"manifest.json": "d645344dc3686eaef7d900bc01c666e9",
"version.json": "5ff952ab85aec78f81c041c1e0be3f21"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
