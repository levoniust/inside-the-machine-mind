import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../widgets/bit.dart';

/// One picture in the gallery manifest (assets/gallery/gallery.json).
class GalleryImage {
  const GalleryImage(this.file, this.title, this.prompt, this.seconds);
  final String file, title, prompt;
  final double seconds;
}

class GalleryData {
  const GalleryData(this.model, this.gpu, this.license, this.images);
  final String model, gpu, license;
  final List<GalleryImage> images;

  static Future<GalleryData> load(AssetBundle bundle) async {
    final j = jsonDecode(await bundle.loadString('assets/gallery/gallery.json')) as Map<String, dynamic>;
    return GalleryData(
      j['model'] as String,
      j['gpu'] as String,
      j['license'] as String,
      [
        for (final i in j['images'] as List)
          GalleryImage(i['file'] as String, i['title'] as String, i['prompt'] as String, (i['seconds'] as num).toDouble()),
      ],
    );
  }
}

/// Easter egg 2: "The 3060 Gallery" — pictures painted by the RTX 3060 in Tim's homelab server.
class EggGalleryScreen extends StatefulWidget {
  const EggGalleryScreen({super.key});

  @override
  State<EggGalleryScreen> createState() => _EggGalleryScreenState();
}

class _EggGalleryScreenState extends State<EggGalleryScreen> {
  late final Future<GalleryData> _data = GalleryData.load(rootBundle);

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 700;
    return Scaffold(
      appBar: AppBar(title: const Text('The 3060 Gallery')),
      body: FutureBuilder<GalleryData>(
        future: _data,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final d = snap.data!;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(Gap.l, Gap.s, Gap.l, Gap.l),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BitAvatar(size: 52, mood: BitMood.wow),
                      const SizedBox(width: Gap.m),
                      Expanded(
                        child: Text(
                          'You found the secret gallery! Every picture here was painted by a graphics card, an '
                          '${d.gpu}, using an image model (${d.model}). A language model wrote the descriptions. '
                          'Tap a picture to see what it was asked to draw.',
                          style: TextStyle(color: c.text),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: Gap.l),
                sliver: SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: wide ? 4 : 2,
                    mainAxisSpacing: Gap.m,
                    crossAxisSpacing: Gap.m,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: d.images.length,
                  itemBuilder: (context, i) => _Tile(key: ValueKey('gallery-$i'), image: d.images[i], data: d),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(Gap.l),
                  child: Text('Images: ${d.license}.', textAlign: TextAlign.center, style: TextStyle(color: c.textDim, fontSize: 12)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({super.key, required this.image, required this.data});
  final GalleryImage image;
  final GalleryData data;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _Viewer(image: image, data: data))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Hero(
                tag: image.file,
                child: Image.asset(image.file, fit: BoxFit.cover, width: double.infinity, semanticLabel: image.title),
              ),
            ),
          ),
          const SizedBox(height: Gap.xs),
          Text(image.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: c.text, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Viewer extends StatelessWidget {
  const _Viewer({required this.image, required this.data});
  final GalleryImage image;
  final GalleryData data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white, title: Text(image.title)),
      body: ListView(
        children: [
          InteractiveViewer(
            maxScale: 4,
            child: Hero(tag: image.file, child: Image.asset(image.file, fit: BoxFit.contain)),
          ),
          Padding(
            padding: const EdgeInsets.all(Gap.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Painted in ${image.seconds.toStringAsFixed(0)} seconds on the ${data.gpu}',
                    style: const TextStyle(color: Color(0xFFFFB547), fontWeight: FontWeight.w700)),
                const SizedBox(height: Gap.m),
                const Text('What it was asked to draw:', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: Gap.xs),
                Text(image.prompt, style: const TextStyle(color: Colors.white, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
