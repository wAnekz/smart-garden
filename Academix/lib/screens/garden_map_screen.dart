import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlantPassport {
  final String id;
  final String name;
  final String species;
  final String plantedBy;
  final String date;
  final int health;
  final double top;
  final double left;
  final String aiRecommendation;

  PlantPassport({
    required this.id,
    required this.name,
    required this.species,
    required this.plantedBy,
    required this.date,
    required this.health,
    required this.top,
    required this.left,
    required this.aiRecommendation,
  });
}

class GardenMapScreen extends StatefulWidget {
  const GardenMapScreen({super.key});

  @override
  State<GardenMapScreen> createState() => _GardenMapScreenState();
}

class _GardenMapScreenState extends State<GardenMapScreen> {
  final TransformationController _transformationController = TransformationController();

  // РАЗМЕРЫ ВАШЕЙ КАРТЫ
  final double mapWidth = 1500.0;
  final double mapHeight = 2000.0;

  final List<PlantPassport> schoolPlants = [
    PlantPassport(
      id: '1',
      name: 'Главный вход',
      species: 'Ель Тянь-Шаньская',
      plantedBy: 'Администрация',
      date: '01.09.2022',
      health: 98,
      top: 850, left: 1100,
      aiRecommendation: 'Состояние идеальное. Полив не требуется.',
    ),
    PlantPassport(
      id: '2',
      name: 'Северное крыло',
      species: 'Березовая аллея',
      plantedBy: '11 "А" класс',
      date: '10.05.2023',
      health: 45,
      top: 600, left: 650,
      aiRecommendation: 'Обнаружен дефицит азота. Рекомендуется подкормка.',
    ),
    PlantPassport(
      id: '3',
      name: 'Внутренний двор',
      species: 'Розарий',
      plantedBy: 'Эко-клуб',
      date: '15.06.2023',
      health: 80,
      top: 850, left: 850,
      aiRecommendation: 'Влажность почвы в норме. Прогноз цветения: 3 дня.',
    ),
    PlantPassport(
      id: '4',
      name: 'Южное крыло',
      species: 'Кустарники',
      plantedBy: '9 "Б" класс',
      date: '20.09.2023',
      health: 20,
      top: 1100, left: 650,
      aiRecommendation: 'Критический уровень! Срочно проверьте датчик влажности.',
    ),
    PlantPassport(
      id: '5',
      name: 'Дальние теплицы',
      species: 'Экзотические виды',
      plantedBy: 'Биологи',
      date: '12.04.2024',
      health: 90,
      top: 1600, left: 300,
      aiRecommendation: 'Оптимальный микроклимат.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerMap();
    });
  }

  void _centerMap() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Множитель 1.8 сделает карту крупнее при старте крч меняй число если хочешь разный первоначальный зум
    // Чем больше число, тем ближе зум.
    double initialScale = (screenWidth / mapWidth) * 2;

    // Центрируем камеру на середине карты
    double xOffset = (screenWidth - mapWidth * initialScale) / 2;
    double yOffset = (screenHeight - mapHeight * initialScale) / 2;

    _transformationController.value = Matrix4.identity()
      ..translate(xOffset, yOffset) // Сдвигаем в центр
      ..scale(initialScale);        // Применяем зум
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("Цифровой Генплан 165", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: _centerMap,
          )
        ],
      ),
      body: InteractiveViewer(
        transformationController: _transformationController,
        boundaryMargin: const EdgeInsets.all(800),
        minScale: 0.05,
        maxScale: 3.0,
        constrained: false,
        child: SizedBox(
          width: mapWidth,
          height: mapHeight,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: LyceumGiantPainter(mapWidth, mapHeight)),
              ),
              ...schoolPlants.map((plant) => Positioned(
                top: plant.top,
                left: plant.left,
                child: _buildMarker(plant),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarker(PlantPassport plant) {
    Color col = plant.health > 70 ? Colors.green : (plant.health > 30 ? Colors.orange : Colors.red);
    return GestureDetector(
      onTap: () => _showSheet(plant),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: col, width: 3),
              boxShadow: [BoxShadow(color: col.withOpacity(0.3), blurRadius: 15)],
            ),
            child: Icon(Icons.eco, color: col, size: 32),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12)
            ),
            child: Text(plant.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSheet(PlantPassport plant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plant.name, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1B5E20))),
                        Text(plant.species, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600], fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                  _buildHealthRing(plant.health),
                ],
              ),
              const Divider(height: 40),
              Row(
                children: [
                  _buildQuickInfo(Icons.calendar_today, "Посадка", plant.date),
                  const SizedBox(width: 20),
                  _buildQuickInfo(Icons.person_outline, "Автор", plant.plantedBy),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.green.shade800, Colors.green.shade600]),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(plant.aiRecommendation, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthRing(int health) {
    Color color = health > 70 ? Colors.green : (health > 30 ? Colors.orange : Colors.red);
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(width: 50, height: 50, child: CircularProgressIndicator(value: health / 100, color: color, backgroundColor: color.withOpacity(0.1))),
        Text("$health%", style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildQuickInfo(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.green),
          const SizedBox(width: 8),
          Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          ])),
        ],
      ),
    );
  }
}

class LyceumGiantPainter extends CustomPainter {
  final double mapWidth;
  final double mapHeight;
  LyceumGiantPainter(this.mapWidth, this.mapHeight);

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final stroke = Paint()..color = const Color(0xFF1B5E20).withOpacity(0.2)..style = PaintingStyle.stroke..strokeWidth = 4;

    // Сетка
    var grid = Paint()..color = Colors.grey.withOpacity(0.1);
    for (double i = 0; i < mapWidth; i += 60) { canvas.drawLine(Offset(i, 0), Offset(i, mapHeight), grid); }
    for (double i = 0; i < mapHeight; i += 60) { canvas.drawLine(Offset(0, i), Offset(mapWidth, i), grid); }

    // Здание
    Path p = Path();
    p.moveTo(1200, 600); p.lineTo(1200, 1100); p.lineTo(600, 1100); p.lineTo(600, 1000);
    p.lineTo(1100, 1000); p.lineTo(1100, 700); p.lineTo(600, 700); p.lineTo(600, 600);
    p.close();

    canvas.drawPath(p, fill);
    canvas.drawPath(p, stroke);

    // Стадион - ИСПРАВЛЕНО ЗДЕСЬ
    canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          200, 1300, 800, 1800,
          topLeft: const Radius.circular(100),
          topRight: const Radius.circular(100),
          bottomLeft: const Radius.circular(100),
          bottomRight: const Radius.circular(100),
        ),
        stroke
    );
  }

  @override bool shouldRepaint(old) => false;
}