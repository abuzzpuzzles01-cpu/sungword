package br.com.emotiondigital.trespalavrinhas;

import android.os.Bundle;
import android.view.View;
import android.widget.ProgressBar;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;
import java.util.List;

public class HomeActivity extends AppCompatActivity {

    private RecyclerView recyclerViewSongs;
    private ProgressBar progressBar;
    private SongsAdapter songsAdapter;
    private List<Song> songList;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

        recyclerViewSongs = findViewById(R.id.recyclerViewSongs);
        progressBar = findViewById(R.id.progressBar);

        setupRecyclerView();
        loadSongs();
    }

    private void setupRecyclerView() {
        songList = new ArrayList<>();
        
        // Exibe em grade de 2 colunas
        recyclerViewSongs.setLayoutManager(new GridLayoutManager(this, 2));
        
        songsAdapter = new SongsAdapter(this, songList, song -> {
            // Callback de clique no item
            if (song.isFree() || song.isDownloaded(this)) {
                // Abre o player de vídeo
                ExecutaVideoActivity.start(HomeActivity.this, song);
            } else {
                // Inicia o download da música/vídeo
                downloadSong(song);
            }
        });

        recyclerViewSongs.setAdapter(songsAdapter);
    }

    /**
     * Carrega a lista de músicas/DVDs do aplicativo.
     */
    private void loadSongs() {
        progressBar.setVisibility(View.VISIBLE);

        // Exemplo de inclusão dos itens dos DVDs
        songList.clear();
        songList.add(new Song("dvd1_o_sabao", "O Sabão", "video_dvd1_o_sabao.mp4", true));
        songList.add(new Song("dvd1_3_palavrinhas", "3 Palavrinhas", "video_dvd1_tres_palavrinhas.mp4", true));
        songList.add(new Song("dvd2_deus_e_bom_pra_mim", "Deus é Bom Pra Mim", "video_dvd2_deus_e_bom_pra_mim.mp4", true));
        songList.add(new Song("dvd2_trenzinho", "Trenzinho", "video_dvd2_trenzinho.mp4", true)); 
        songList.add(new Song("dvd3_dentro_fora_alto_embaixo", "Por Dentro, Fora, Alto, Embaixo", "video_dvd3_dentro_fora_alto_embaixo.mp4", true));
        songList.add(new Song("dvd3_meu_bom_pastor", "Meu Bom Pastor", "video_dvd3_meu_bom_pastor.mp4", true));
        songList.add(new Song("dormir_o_sabao", "O Sabão", "video_dormir_o_sabao.mp4", true));
        songList.add(new Song("dormir_3_palavrinhas", "Deus é Amor", "video_dormir_tres_palavrinhas.mp4", true));
        songList.add(new Song("tlw_soap", "Soap", "video_tlw_soap.mp4", true));
        songList.add(new Song("tlw_3_little_words", "3 Little Words", "video_tlw_three_little_words.mp4", true));

        songsAdapter.notifyDataSetChanged();
        progressBar.setVisibility(View.GONE);
    }

    /**
     * Simulação da lógica de download do conteúdo.
     */
    private void downloadSong(Song song) {
        Toast.makeText(this, "Iniciando download: " + song.getTitle(), Toast.LENGTH_SHORT).show();
    }

    @Override
    protected void onResume() {
        super.onResume();
        // Atualiza o estado da lista ao retornar de outras telas
        if (songsAdapter != null) {
            songsAdapter.notifyDataSetChanged();
        }
    }
}
