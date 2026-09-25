package br.com.emotiondigital.trespalavrinhas;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import java.util.List;

public class SongsAdapter extends RecyclerView.Adapter<SongsAdapter.SongViewHolder> {

    public interface OnSongClickListener {
        void onSongClick(Song song, int position);
    }

    private final Context context;
    private final List<Song> songs;
    private final OnSongClickListener listener;

    public SongsAdapter(Context context, List<Song> songs, OnSongClickListener listener) {
        this.context = context;
        this.songs = songs;
        this.listener = listener;
    }

    @NonNull
    @Override
    public SongViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.item_song_card, parent, false);
        return new SongViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull SongViewHolder holder, int position) {
        Song song = songs.get(position);

        holder.txtTitle.setText(song.getTitle());

        // Carrega a imagem da thumbnail dinâmica a partir dos recursos drawable
        String thumbName = song.getCleanId().startsWith("video_") ? song.getCleanId() : "video_" + song.getCleanId();
        int imageResId = context.getResources().getIdentifier(thumbName, "drawable", context.getPackageName());
        
        if (imageResId != 0) {
            holder.imgThumb.setImageResource(imageResId);
        } else {
            holder.imgThumb.setImageResource(R.drawable.bg_splash); // Drawable padrão de fallback
        }

        // Ícone de status (Baixado, Grátis ou Download pendente)
        if (song.isFree() || song.isDownloaded(context)) {
            holder.imgStatus.setImageResource(R.drawable.ic_play_circle);
        } else {
            holder.imgStatus.setImageResource(R.drawable.ic_download);
        }

        holder.itemView.setOnClickListener(v -> {
            if (listener != null) {
                listener.onSongClick(song, position);
            }
        });
    }

    @Override
    public int getItemCount() {
        return songs != null ? songs.size() : 0;
    }

    static class SongViewHolder extends RecyclerView.ViewHolder {
        ImageView imgThumb;
        ImageView imgStatus;
        TextView txtTitle;

        public SongViewHolder(@NonNull View itemView) {
            super(itemView);
            imgThumb = itemView.findViewById(R.id.imgThumb);
            imgStatus = itemView.findViewById(R.id.imgStatus);
            txtTitle = itemView.findViewById(R.id.txtTitle);
        }
    }
}
