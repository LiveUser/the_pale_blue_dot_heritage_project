class Model{
  Model({
    required this.title,
    required this.modelName,
    required this.description,
    required this.universityID,
    required this.zenodoDigitalObjectIdentifier,
    required this.locationFound,
    required this.dateTimeFound,
  });
  final String title;
  //3d model name
  final String modelName;
  //Description file name
  final String? description;
  final String? universityID;
  final String zenodoDigitalObjectIdentifier;
  final String? locationFound;
  final DateTime? dateTimeFound;
}
List<Model> allModels = [
  Model(
    title: "Primera canoa descubierta en Puerto Rico", 
    modelName: "canoa_compressed.glb",
    description: null,
    universityID: null, 
    zenodoDigitalObjectIdentifier: "https://doi.org/10.5281/zenodo.19646003", 
    locationFound: null, 
    dateTimeFound: null,
  ),
  Model(
    title: "Mural de petroglifos de Salto Arriba", 
    modelName: "mural_de_petroglifos_de_salto_arriba_compressed.glb",
    description: "mural-de-petroglifos-de-salto-arriba.txt",
    universityID: null, 
    zenodoDigitalObjectIdentifier: "https://doi.org/10.5281/zenodo.19645885", 
    locationFound: null, 
    dateTimeFound: null,
  ),
  Model(
    title: "Sellos Indígenas", 
    modelName: "24.0012.8_compressed.glb",
    description: null,
    universityID: "24.0012.8", 
    zenodoDigitalObjectIdentifier: "https://doi.org/10.5281/zenodo.19646230", 
    locationFound: null, 
    dateTimeFound: null,
  ),
];