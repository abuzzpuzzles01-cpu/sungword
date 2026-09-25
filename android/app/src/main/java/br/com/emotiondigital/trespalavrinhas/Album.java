package br.com.emotiondigital.trespalavrinhas;

import android.content.Context;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class Album implements Serializable {

    private String id;
    private String title;
    private String coverImageName;
    private List<Song> songs;

    public Album(String id, String title, String coverImageName, List<Song> songs) {
        this.id = id;
        this.title = title;
        this.coverImageName = coverImageName;
        this.songs = songs != null ? songs : new ArrayList<>();
    }

    // MARK: - Getters e Setters

    public String getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public String getCoverImageName() {
        return coverImageName;
    }

    public List<Song> getSongs() {
        return songs;
    }

    public void setSongs(List<Song> songs) {
        this.songs = songs;
    }

    // MARK: - Métodos de Estado do Álbum

    /**
     * Retorna o total de músicas no álbum.
     */
    public int getSongCount() {
        return songs.size();
    }

    /**
     * Retorna a quantidade de músicas grátis ou que já foram baixadas localmente.
     */
    public int getDownloadedSongsCount(Context context) {
        int count = 0;
        for (Song song : songs) {
            if (song.isFree() || song.isDownloaded(context)) {
                count++;
            }
        }
        return count;
    }

    /**
     * Verifica se o álbum está completo (todas as músicas estão disponíveis localmente).
     */
    public boolean isFullyDownloaded(Context context) {
        if (songs.isEmpty()) return false;
        
        for (Song song : songs) {
            if (!song.isFree() && !song.isDownloaded(context)) {
                return false;
            }
        }
        return true;
    }

    /**
     * Retorna a porcentagem de download do álbum (ex: 0.0 a 1.0).
     */
    public float getDownloadProgress(Context context) {
        if (songs.isEmpty()) return 0f;
        return (float) getDownloadedSongsCount(context) / (float) songs.size();
    }

    // MARK: - Imagem de Capa (Drawable)

    /**
     * Retorna o Resource ID da capa do álbum na pasta `res/drawable/`.
     * Garante a formatação do nome sem extensão e com caracteres válidos para o Android.
     */
    public int getCoverResourceDrawable(Context context) {
        if (coverImageName == null || coverImageName.isEmpty()) {
            return context.getResources().getIdentifier("bg_splash", "drawable", context.getPackageName());
        }

        String imageName = coverImageName.toLowerCase();
        
        // Remove extensão caso exista (.png, .jpg)
        if (imageName.contains(".")) {
            imageName = imageName.substring(0, imageName.lastIndexOf('.'));
        }

        int resId = context.getResources().getIdentifier(imageName, "drawable", context.getPackageName());

        // Fallback caso a imagem não exista em res/drawable/
        if (resId == 0) {
            resId = context.getResources().getIdentifier("bg_splash", "drawable", context.getPackageName());
        }

        return resId;
    }
}
package br.com.emotiondigital.trespalavrinhas.model;

import com.google.gson.annotations.SerializedName;
import java.io.Serializable;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public class Album implements Serializable {
    private static final String DVD_1 = "br.com.emotiondigital.trespalavrinhas.dvd1";
    private static final String DVD_2 = "br.com.emotiondigital.trespalavrinhas.dvd2";
    private static final String HORA_DORMIR = "br.com.emotiondigital.trespalavrinhas.hora_dormir";

    @SerializedName("ProductId")
    private int identifier;

    @SerializedName("StoreId")
    private String productIdentifier;

    @SerializedName("Contents")
    private List<Song> songs;

    public String getAlbumName() {
        switch (getProductIdentifier()) {
            case "br.com.emotiondigital.trespalavrinhas.dvd1":
                return "DVD 1";
            case "br.com.emotiondigital.trespalavrinhas.dvd2":
                return "DVD 2";
            case "br.com.emotiondigital.trespalavrinhas.hora_dormir":
                return "Hora de Dormir";
            default:
                return null;
        }
    }

    public int getOrder() {
        switch (getProductIdentifier()) {
            case "br.com.emotiondigital.trespalavrinhas.dvd1":
                return 0;
            case "br.com.emotiondigital.trespalavrinhas.dvd2":
                return 1;
            case "br.com.emotiondigital.trespalavrinhas.hora_dormir":
                return 2;
            default:
                return -1;
        }
    }

    public int getIdentifier() {
        return this.identifier;
    }

    public void setIdentifier(int identifier) {
        this.identifier = identifier;
    }

    public String getProductIdentifier() {
        return this.productIdentifier;
    }

    public void setProductIdentifier(String productIdentifier) {
        this.productIdentifier = productIdentifier;
    }

    public List<Song> getSongs() {
        return this.songs;
    }

    public void setSongs(List<Song> songs) {
        this.songs = songs;
    }
}
