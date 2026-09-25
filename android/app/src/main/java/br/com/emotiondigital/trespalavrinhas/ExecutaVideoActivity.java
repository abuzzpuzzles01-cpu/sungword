package br.com.emotiondigital.trespalavrinhas;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageButton;
import android.widget.ProgressBar;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.media3.common.MediaItem;
import androidx.media3.common.PlaybackException;
import androidx.media3.common.Player;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.ui.PlayerView;

public class ExecutaVideoActivity extends AppCompatActivity {

    public static final String EXTRA_SONG = "extra_song";

    private PlayerView playerView;
    private ProgressBar loadingPlayer;
    private ImageButton btnBack;
    
    private ExoPlayer player;
    private Song currentSong;

    /**
     * Método utilitário para abrir esta Activity a partir de qualquer contexto.
     */
    public static void start(Context context, Song song) {
        Intent intent = new Intent(context, ExecutaVideoActivity.class);
        intent.putExtra(EXTRA_SONG, song);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Esconde as barras de sistema para modo Imersivo (Fullscreen)
        hideSystemUI();
        setContentView(R.layout.activity_executa_video);

        playerView = findViewById(R.id.playerView);
        loadingPlayer = findViewById(R.id.loadingPlayer);
        btnBack = findViewById(R.id.btnBack);

        if (getIntent() != null && getIntent().hasExtra(EXTRA_SONG)) {
            currentSong = (Song) getIntent().getSerializableExtra(EXTRA_SONG);
        }

        if (currentSong == null) {
            Toast.makeText(this, "Erro ao carregar o vídeo", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        btnBack.setOnClickListener(v -> finish());
    }

    private void initializePlayer() {
        if (currentSong == null) return;

        Uri videoUri = currentSong.getVideoUri(this);
        if (videoUri == null) {
            Toast.makeText(this, "Vídeo indisponível", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        // Instancia o ExoPlayer
        player = new ExoPlayer.Builder(this).build();
        playerView.setPlayer(player);

        // Prepara a mídia
        MediaItem mediaItem = MediaItem.fromUri(videoUri);
        player.setMediaItem(mediaItem);
        player.setPlayWhenReady(true);
        player.prepare();

        // Ouvinte de eventos do player (Buffering, Erros)
        player.addListener(new Player.Listener() {
            @Override
            public void onPlaybackStateChanged(int playbackState) {
                if (playbackState == Player.STATE_BUFFERING) {
                    loadingPlayer.setVisibility(View.VISIBLE);
                } else if (playbackState == Player.STATE_READY) {
                    loadingPlayer.setVisibility(View.GONE);
                } else if (playbackState == Player.STATE_ENDED) {
                    // Opcional: fechar ao terminar ou repetir
                }
            }

            @Override
            public void onPlayerError(PlaybackException error) {
                loadingPlayer.setVisibility(View.GONE);
                Toast.makeText(ExecutaVideoActivity.this, "Erro ao reproduzir vídeo", Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void releasePlayer() {
        if (player != null) {
            player.release();
            player = null;
        }
    }

    // MARK: - Ciclo de Vida do Android

    @Override
    protected void onStart() {
        super.onStart();
        initializePlayer();
    }

    @Override
    protected void onResume() {
        super.onResume();
        hideSystemUI();
        if (player != null) {
            player.play();
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (player != null) {
            player.pause();
        }
    }

    @Override
    protected void onStop() {
        super.onStop();
        releasePlayer();
    }

    // MARK: - Layout Imersivo (Tela Cheia)

    private void hideSystemUI() {
        View decorView = getWindow().getDecorView();
        decorView.setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                        | View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                        | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                        | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                        | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                        | View.SYSTEM_UI_FLAG_FULLSCREEN);
    }
}
