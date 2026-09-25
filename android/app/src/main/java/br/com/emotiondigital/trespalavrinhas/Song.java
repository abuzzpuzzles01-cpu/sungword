package br.com.emotiondigital.trespalavrinhas;

import android.content.Context;
import android.net.Uri;
import java.io.File;
import java.io.Serializable;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

public class Song implements Serializable {
    private String id;
    private String title;
    private String fileName;

    private static final String BASE_URL = "https://newabuzzassets.b-cdn.net/assets/tres_palavrinhas";

    public Song(String id, String title, String fileName) {
        this.id = id;
        this.title = title;
        this.fileName = fileName;
    }

    public String getId() { return id; }
    public String getTitle() { return title; }
    public String getFileName() { return fileName; }

    // MARK: - Normalização do Nome
    public String getCleanId() {
        String name = (fileName != null && !fileName.isEmpty()) ? fileName : id;
        if (name == null) return "";
        
        // Remove a extensão .mp4 caso venha na string
        if (name.contains(".")) {
            name = name.substring(0, name.lastIndexOf('.'));
        }
        return name.toLowerCase();
    }

    /// Retorna a string do recurso no formato esperado em res/raw/ (ex: "video_dvd1_o_sabao")
    public String getRawResourceName() {
        String clean = getCleanId();
        return clean.startsWith("video_") ? clean : "video_" + clean;
    }

    // MARK: - Músicas Grátis
    public boolean isFree() {
        String clean = getCleanId();
        String normalized = clean.startsWith("video_") ? clean.substring(6) : clean;

        Set<String> freeSongs = new HashSet<>(Arrays.asList(
            "dvd1_o_sabao",          // DVD 1
            "dvd2_pare",             // DVD 2
            "dvd3_meu_melhor_amigo", // DVD 3
            "dormir_o_sabao",        // Hora de Dormir
            "tlw_soap"               // Inglês
        ));

        return freeSongs.contains(normalized);
    }

    // MARK: - Resolver de URI do Vídeo
    public Uri getVideoUri(Context context) {
        String rawName = getRawResourceName();

        // 1. MÚSICA GRÁTIS: Busca na pasta res/raw/ do Android
        if (isFree()) {
            int resId = context.getResources().getIdentifier(rawName, "raw", context.getPackageName());
            
            // Fallback caso o recurso não tenha o prefixo video_ no raw
            if (resId == 0) {
                resId = context.getResources().getIdentifier(getCleanId(), "raw", context.getPackageName());
            }

            if (resId != 0) {
                // Constrói a URI do recurso interno res/raw/
                return Uri.parse("android.resource://" + context.getPackageName() + "/" + resId);
            } else {
                System.err.println("❌ [ERRO RAW]: O recurso 'R.raw." + rawName + "' não foi encontrado!");
            }
        }

        // 2. MÚSICA PAGA BAIXADA LOCALMENTE (Armazenamento Interno/Documentos)
        if (isDownloaded(context)) {
            File localFile = getLocalVideoFile(context);
            return Uri.fromFile(localFile);
        }

        // 3. MÚSICA PAGA REMOTA (Streaming via CDN)
        String downloadUrl = getDownloadURL();
        if (downloadUrl != null) {
            return Uri.parse(downloadUrl);
        }

        return null;
    }

    public String getDownloadURL() {
        String clean = getCleanId();
        String normalized = clean.startsWith("video_") ? clean.substring(6) : clean;
        return BASE_URL + "/" + normalized + ".mp4";
    }

    public File getLocalVideoFile(Context context) {
        File dir = context.getExternalFilesDir(null);
        return new File(dir, getRawResourceName() + ".mp4");
    }

    public boolean isDownloaded(Context context) {
        if (isFree()) return true;
        File file = getLocalVideoFile(context);
        return file.exists() && file.length() > 0;
    }
}
