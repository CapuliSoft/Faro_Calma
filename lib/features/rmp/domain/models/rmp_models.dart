import 'package:flutter/material.dart';

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

extension LocalizedMuscleGroup on MuscleGroup {
  String getLocalizedName(BuildContext context) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    if (isEs) return name;
    switch (id) {
      case 'manoDerecha': return 'Right Hand and Forearm';
      case 'manoIzquierda': return 'Left Hand and Forearm';
      case 'bicepsDerecho': return 'Right Biceps';
      case 'bicepsIzquierdo': return 'Left Biceps';
      case 'frente': return 'Forehead';
      case 'ojosNariz': return 'Eyes and Nose';
      case 'mandibula': return 'Jaw';
      case 'cuello': return 'Neck and Throat';
      case 'hombros': return 'Shoulders';
      case 'espalda': return 'Upper Back';
      case 'abdomen': return 'Abdomen';
      case 'muslos': return 'Thighs';
      case 'pantorrillas': return 'Calves';
      case 'pies': return 'Feet';
    }
    return name;
  }

  String getLocalizedCategory(BuildContext context) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    if (isEs) return category;
    switch (category) {
      case 'Brazos': return 'Arms';
      case 'Cara y Cabeza': return 'Face and Head';
      case 'Cuello y Hombros': return 'Neck and Shoulders';
      case 'Torso': return 'Torso';
      case 'Piernas y Pies': return 'Legs and Feet';
    }
    return category;
  }

  List<String> getLocalizedTensionSteps(BuildContext context) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    if (isEs) return tensionSteps;
    switch (id) {
      case 'manoDerecha':
        return [
          'Make a tight fist with your right hand',
          'Squeeze tightly',
          'Feel the tension in your fingers and forearm',
        ];
      case 'manoIzquierda':
        return [
          'Make a tight fist with your left hand',
          'Squeeze tightly',
          'Feel the tension in your fingers and forearm',
        ];
      case 'bicepsDerecho':
        return [
          'Bend your right elbow and tense your biceps',
          'Squeeze hard towards your shoulder',
          'Feel the tension in your upper arm',
        ];
      case 'bicepsIzquierdo':
        return [
          'Bend your left elbow and tense your biceps',
          'Squeeze hard towards your shoulder',
          'Feel the tension in your upper arm',
        ];
      case 'frente':
        return [
          'Raise your eyebrows as high as possible',
          'Wrinkle your forehead tightly',
          'Feel the tension above your eyebrows',
        ];
      case 'ojosNariz':
        return [
          'Close your eyes tightly',
          'Wrinkle your nose upwards',
          'Feel the pressure in the center of your face',
        ];
      case 'mandibula':
        return [
          'Clench your teeth firmly',
          'Tense your cheeks and jaw',
          'Feel the stiffness in your jaw',
        ];
      case 'cuello':
        return [
          'Bring your chin slowly down to your chest',
          'Tense the front muscles of your neck',
          'Feel the contraction in your throat',
        ];
      case 'hombros':
        return [
          'Shrug your shoulders up to your ears',
          'Squeeze tightly upwards',
          'Feel the tension in your shoulders and neck',
        ];
      case 'espalda':
        return [
          'Pull your elbows back trying to bring shoulder blades together',
          'Arch your upper back slightly',
          'Feel the muscle contraction in your back',
        ];
      case 'abdomen':
        return [
          'Make your stomach hard and tense',
          'As if preparing to receive a gentle blow',
          'Feel the tension in the abdominal wall',
        ];
      case 'muslos':
        return [
          'Squeeze your legs and tense your thighs',
          'As if pushing the floor hard',
          'Feel the firmness in your legs',
        ];
      case 'pantorrillas':
        return [
          'Point your toes down extending your ankles',
          'Tense your calves firmly',
          'Feel the tension in the back of your leg',
        ];
      case 'pies':
        return [
          'Curl your toes inward',
          'Squeeze the arch of your foot tightly',
          'Feel the accumulated tension in your foot',
        ];
    }
    return tensionSteps;
  }

  List<String> getLocalizedRelaxationSteps(BuildContext context) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    if (isEs) return relaxationSteps;
    switch (id) {
      case 'manoDerecha':
        return [
          'Open your right hand completely',
          'Let it fall loose and limp',
          'Feel your fingers naturally relaxed and at rest',
        ];
      case 'manoIzquierda':
        return [
          'Open your left hand completely',
          'Let it fall loose and limp',
          'Feel your fingers naturally relaxed and at rest',
        ];
      case 'bicepsDerecho':
        return [
          'Extend your right arm gently',
          'Let the arm rest in your lap or side',
          'Feel the arm completely free of tension',
        ];
      case 'bicepsIzquierdo':
        return [
          'Extend your left arm gently',
          'Let the arm rest in your lap or side',
          'Feel the arm completely free of tension',
        ];
      case 'frente':
        return [
          'Release your eyebrows and relax your forehead',
          'Imagine your forehead as smooth as a calm lake',
          'Feel the skin soft and wrinkle-free',
        ];
      case 'ojosNariz':
        return [
          'Gently release your eyelids',
          'Let your nose rest',
          'Eyes closed in a soft and natural way',
        ];
      case 'mandibula':
        return [
          'Release your teeth and open your mouth slightly',
          'Let your jaw drop loose',
          'Feel how your cheeks relax',
        ];
      case 'cuello':
        return [
          'Return your head to a comfortable position',
          'Leave your neck loose and relaxed',
          'Feel the balanced weight of your head',
        ];
      case 'hombros':
        return [
          'Drop your shoulders suddenly',
          'Feel them fall heavy and rested',
          'Imagine your shoulders melting downwards',
        ];
      case 'espalda':
        return [
          'Release your elbows and relax your back',
          'Let your shoulders rest forward',
          'Feel your back wide, released and at peace',
        ];
      case 'abdomen':
        return [
          'Release your stomach completely',
          'Let it inflate gently as you breathe',
          'Enjoy a deep and calm breath',
        ];
      case 'muslos':
        return [
          'Release your thigh muscles',
          'Leave your legs completely loose',
          'Feel the support of the seat or bed',
        ];
      case 'pantorrillas':
        return [
          'Release your ankles and relax your feet',
          'Let your feet point naturally to the sides',
          'Feel your calves soft and heavy',
        ];
      case 'pies':
        return [
          'Release your toes and relax the arch of your foot',
          'Leave your feet completely loose and warm',
          'Feel your feet free of all tension',
        ];
    }
    return relaxationSteps;
  }
}
