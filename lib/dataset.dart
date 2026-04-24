class Model{
  Model({
    required this.title,
    required this.description,
    required this.zenodoDigitalObjectIdentifier,
    required this.objectUUID,
  });
  final String title;
  //Description file name
  final String description;
  final String zenodoDigitalObjectIdentifier;
  final String objectUUID;
}