package br.com.emotiondigital.trespalavrinhas;

import com.google.gson.annotations.SerializedName;
import java.io.Serializable;

public class Song implements Serializable {

    @SerializedName("id")
    private String id;

    @SerializedName("title")
    private String title;

    @SerializedName("videoName")
    private String videoName;

    @SerializedName("isDownloaded")
    private boolean isDownloaded;

    public Song() {
    }

    public Song(String id, String title, String videoName) {
        this.id = id;
        this.title = title;
        this.videoName = videoName;
        this.isDownloaded = false;
    }

    public Song(String id, String title, String videoName, boolean isDownloaded) {
        this.id = id;
        this.title = title;
        this.videoName = videoName;
        this.isDownloaded = isDownloaded;
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

    public String getVideoName() {
        return videoName;
    }

    public void setVideoName(String videoName) {
        this.videoName = videoName;
    }

    public boolean isDownloaded() {
        return isDownloaded;
    }

    public void setDownloaded(boolean downloaded) {
        isDownloaded = downloaded;
    }
}
