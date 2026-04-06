class SemaphoreModel {
  final String letter;
  final double right; // sudut siku kanan
  final double left; // sudut siku kiri

  const SemaphoreModel(this.letter, this.right, this.left);
}

const List<SemaphoreModel> semaphoreList = [
  SemaphoreModel('A', 225, 135),
  SemaphoreModel('B', 0, 180),
  SemaphoreModel('C', 45, 180),
  SemaphoreModel('D', 90, 180),
  SemaphoreModel('E', 135, 180),
  SemaphoreModel('F', 180, 135),
  SemaphoreModel('G', 180, 90),
  SemaphoreModel('H', 180, 45),
  SemaphoreModel('I', 180, 0),
  SemaphoreModel('J', 135, 0),
  SemaphoreModel('K', 90, 45),
  SemaphoreModel('L', 90, 0),
  SemaphoreModel('M', 45, 0),
  SemaphoreModel('N', 0, 45),
  SemaphoreModel('O', 45, 90),
  SemaphoreModel('P', 0, 90),
  SemaphoreModel('Q', 45, 135),
  SemaphoreModel('R', 90, 135),
  SemaphoreModel('S', 135, 90),
  SemaphoreModel('T', 135, 45),
  SemaphoreModel('U', 90, 180),
  SemaphoreModel('V', 45, 180),
  SemaphoreModel('W', 180, 180),
  SemaphoreModel('X', 135, 135),
  SemaphoreModel('Y', 90, 90),
  SemaphoreModel('Z', 45, 45),
];
