const String apiURL = "https://man-well-sharply.ngrok-free.app";
const String proxyURL = "https://zenodo-proxy.valentin-radames.workers.dev/";

Uri getRedirectURL(String zenodoURL){
  Uri url = Uri.parse(proxyURL).replace(
    path: "/redirect",
    queryParameters: {
      "url": zenodoURL,
    },
  );
  return url;
}