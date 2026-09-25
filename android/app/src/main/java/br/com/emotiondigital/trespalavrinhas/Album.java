package br.com.emotiondigital.trespalavrinhas;

import com.google.gson.annotations.SerializedName;
import java.io.Serializable;
import java.util.List;

public class Album implements Serializable {

    @SerializedName("id")
    private String id;

    @SerializedName("title")
    private String title;

    @SerializedName("coverUrl")
    private String coverUrl;

    @SerializedName("songs")
    private List<Song> songs;

    public Album() {
    }

    public Album(String id, String title, String coverUrl, List<Song> songs) {
        this.id = id;
        this.title = title;
        this.coverUrl = coverUrl;
        this.songs = songs;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getCoverUrl() {
        return coverUrl;
    }

    public void setCoverUrl(String coverUrl) {
        this.coverUrl = coverUrl;
    }

    public List<Song> getSongs() {
        return songs;
    }

    public void setSongs(List<Song> songs) {
        this.songs = songs;
    }
}

