class MuscleGroup {
  final String id;
  final String name;
  final String category;
  final String tensionEmoji;
  final String relaxationEmoji;
  final List<String> tensionSteps;
  final List<String> relaxationSteps;

  const MuscleGroup({
    required this.id,
    required this.name,
    required this.category,
    required this.tensionEmoji,
    required this.relaxationEmoji,
    required this.tensionSteps,
    required this.relaxationSteps,
  });

  String emoji(bool isTension) => isTension ? tensionEmoji : relaxationEmoji;
}

class RmpSessionConfig {
  final List<MuscleGroup> activeGroups;
  final int totalDurationSeconds;
  final bool soundEnabled;

  const RmpSessionConfig({
    required this.activeGroups,
    required this.totalDurationSeconds,
    required this.soundEnabled,
  });

  int get secondsPerPhase {
    final count = activeGroups.length;
    if (count == 0) return 10;
    // Each group has 2 phases (tension + relaxation)
    return (totalDurationSeconds / (count * 2)).round().clamp(4, 45);
  }
}

// Complete catalog of muscle groups
final List<MuscleGroup> kRmpMuscleGroups = [
  const MuscleGroup(
    id: 'manoDerecha',
    name: 'Mano Derecha y Antebrazo',
    category: 'Brazos',
    tensionEmoji: '✊',
    relaxationEmoji: '🖐️',
    tensionSteps: [
      'Haz un puño apretado con la mano derecha',
      'Aprieta con fuerza',
      'Siente la tensión en tus dedos y antebrazo',
    ],
    relaxationSteps: [
      'Abre tu mano derecha por completo',
      'Déjala caer floja y suelta',
      'Siente los dedos naturalmente relajados y en reposo',
    ],
  ),
  const MuscleGroup(
    id: 'manoIzquierda',
    name: 'Mano Izquierda y Antebrazo',
    category: 'Brazos',
    tensionEmoji: '✊',
    relaxationEmoji: '🖐️',
    tensionSteps: [
      'Haz un puño apretado con la mano izquierda',
      'Aprieta con fuerza',
      'Siente la tensión en tus dedos y antebrazo',
    ],
    relaxationSteps: [
      'Abre tu mano izquierda por completo',
      'Déjala caer floja y suelta',
      'Siente los dedos naturalmente relajados y en reposo',
    ],
  ),
  const MuscleGroup(
    id: 'bicepsDerecho',
    name: 'Bíceps Derecho',
    category: 'Brazos',
    tensionEmoji: '💪',
    relaxationEmoji: '🦾',
    tensionSteps: [
      'Dobla tu codo derecho y tensa el bíceps',
      'Aprieta fuerte hacia tu hombro',
      'Siente la tensión en la parte superior del brazo',
    ],
    relaxationSteps: [
      'Extiende el brazo derecho suavemente',
      'Deja reposar el brazo en tu regazo o al costado',
      'Siente el brazo completamente libre de tensión',
    ],
  ),
  const MuscleGroup(
    id: 'bicepsIzquierdo',
    name: 'Bíceps Izquierdo',
    category: 'Brazos',
    tensionEmoji: '💪',
    relaxationEmoji: '🦾',
    tensionSteps: [
      'Dobla tu codo izquierdo y tensa el bíceps',
      'Aprieta fuerte hacia tu hombro',
      'Siente la tensión en la parte superior del brazo',
    ],
    relaxationSteps: [
      'Extiende el brazo izquierdo suavemente',
      'Deja reposar el brazo en tu regazo o al costado',
      'Siente el brazo completamente libre de tensión',
    ],
  ),
  const MuscleGroup(
    id: 'frente',
    name: 'Frente',
    category: 'Cara y Cabeza',
    tensionEmoji: '😠',
    relaxationEmoji: '😌',
    tensionSteps: [
      'Levanta tus cejas lo más alto posible',
      'Arruga tu frente con fuerza',
      'Siente la tensión sobre tus cejas',
    ],
    relaxationSteps: [
      'Suelta las cejas y relaja la frente',
      'Imagina tu frente lisa como un lago calmado',
      'Siente la piel suave y sin arrugas',
    ],
  ),
  const MuscleGroup(
    id: 'ojosNariz',
    name: 'Ojos y Nariz',
    category: 'Cara y Cabeza',
    tensionEmoji: '😣',
    relaxationEmoji: '😴',
    tensionSteps: [
      'Cierra los ojos con fuerza',
      'Arruga la nariz hacia arriba',
      'Siente la presión en el centro del rostro',
    ],
    relaxationSteps: [
      'Suelta suavemente los párpados',
      'Deja que tu nariz descanse',
      'Ojos cerrados de manera suave y natural',
    ],
  ),
  const MuscleGroup(
    id: 'mandibula',
    name: 'Mandíbula',
    category: 'Cara y Cabeza',
    tensionEmoji: '😬',
    relaxationEmoji: '😮',
    tensionSteps: [
      'Aprieta los dientes firmemente',
      'Tensa las mejillas y la quijada',
      'Siente la dureza en la mandíbula',
    ],
    relaxationSteps: [
      'Suelta los dientes y abre un poco la boca',
      'Deja que tu mandíbula caiga floja',
      'Siente cómo se relajan las mejillas',
    ],
  ),
  const MuscleGroup(
    id: 'cuello',
    name: 'Cuello y Garganta',
    category: 'Cuello y Hombros',
    tensionEmoji: '😤',
    relaxationEmoji: '🧘',
    tensionSteps: [
      'Lleva tu barbilla hacia el pecho lentamente',
      'Tensa los músculos frontales del cuello',
      'Siente la contracción en la garganta',
    ],
    relaxationSteps: [
      'Regresa tu cabeza a una posición cómoda',
      'Deja el cuello suelto y relajado',
      'Siente el peso de la cabeza equilibrado',
    ],
  ),
  const MuscleGroup(
    id: 'hombros',
    name: 'Hombros',
    category: 'Cuello y Hombros',
    tensionEmoji: '🙆',
    relaxationEmoji: '🧎',
    tensionSteps: [
      'Encoge los hombros levantándolos hacia las orejas',
      'Aprieta con fuerza hacia arriba',
      'Siente la tensión en los hombros y cuello',
    ],
    relaxationSteps: [
      'Deja caer los hombros de golpe',
      'Siente cómo caen pesados y descansados',
      'Imagina los hombros derritiéndose hacia abajo',
    ],
  ),
  const MuscleGroup(
    id: 'espalda',
    name: 'Espalda Alta',
    category: 'Torso',
    tensionEmoji: '🏋️',
    relaxationEmoji: '🛀',
    tensionSteps: [
      'Lleva tus codos hacia atrás intentando juntar los omóplatos',
      'Arquea ligeramente la espalda alta',
      'Siente la contracción muscular en la espalda',
    ],
    relaxationSteps: [
      'Suelta los codos y relaja la espalda',
      'Deja que tus hombros descansen al frente',
      'Siente la espalda ancha, liberada y en paz',
    ],
  ),
  const MuscleGroup(
    id: 'abdomen',
    name: 'Abdomen',
    category: 'Torso',
    tensionEmoji: '🫀',
    relaxationEmoji: '🫁',
    tensionSteps: [
      'Pon el estómago duro y tenso',
      'Como si te prepararas para recibir un golpe suave',
      'Siente la tensión en la pared abdominal',
    ],
    relaxationSteps: [
      'Suelta el estómago por completo',
      'Deja que se infle suavemente al respirar',
      'Disfruta una respiración profunda y calmada',
    ],
  ),
  const MuscleGroup(
    id: 'muslos',
    name: 'Muslos',
    category: 'Piernas y Pies',
    tensionEmoji: '🦵',
    relaxationEmoji: '🪑',
    tensionSteps: [
      'Aprieta las piernas y tensa los muslos',
      'Como si empujaras el piso con fuerza',
      'Siente la firmeza en las piernas',
    ],
    relaxationSteps: [
      'Suelta los músculos de los muslos',
      'Deja las piernas completamente flojas',
      'Siente el soporte del asiento o cama',
    ],
  ),
  const MuscleGroup(
    id: 'pantorrillas',
    name: 'Pantorrillas',
    category: 'Piernas y Pies',
    tensionEmoji: '⚡',
    relaxationEmoji: '🦶',
    tensionSteps: [
      'Apunta tus pies hacia el suelo extendiendo los tobillos',
      'Tensa las pantorrillas con firmeza',
      'Siente la tensión en la parte posterior de la pierna',
    ],
    relaxationSteps: [
      'Suelta los tobillos y relaja los pies',
      'Deja los pies apuntando naturalmente hacia los lados',
      'Siente tus pantorrillas suaves y pesadas',
    ],
  ),
  const MuscleGroup(
    id: 'pies',
    name: 'Pies',
    category: 'Piernas y Pies',
    tensionEmoji: '🦶',
    relaxationEmoji: '👣',
    tensionSteps: [
      'Encurva los dedos de los pies hacia adentro',
      'Aprieta el arco del pie con fuerza',
      'Siente la tensión acumulada en el pie',
    ],
    relaxationSteps: [
      'Suelta los dedos y relaja el arco del pie',
      'Deja los pies completamente flojos y tibios',
      'Siente tus pies libres de toda tensión',
    ],
  ),
];
