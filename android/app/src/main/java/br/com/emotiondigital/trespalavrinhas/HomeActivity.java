package br.com.emotiondigital.trespalavrinhas;

import android.content.Intent;
import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;
import java.util.List;

public class HomeActivity extends AppCompatActivity {

    private RecyclerView recyclerViewSongs;
    private SongsAdapter songsAdapter;
    private List<Song> songList;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

        recyclerViewSongs = findViewById(R.id.recyclerViewSongs);
        recyclerViewSongs.setLayoutManager(new LinearLayoutManager(this));

        // Inicializa a lista de músicas
        initSongList();

        songsAdapter = new SongsAdapter(this, songList, song -> {
            Intent intent = new Intent(HomeActivity.this, ExecutaVideoActivity.class);
            intent.putExtra("SONG_KEY", song);
            startActivity(intent);
        });

        recyclerViewSongs.setAdapter(songsAdapter);
    }

    private void initSongList() {
        songList = new ArrayList<>();

        // DVD 1
        songList.add(new Song("dvd1_o_sabao", "O Sabão", "video_dvd1_o_sabao", true));
        songList.add(new Song("dvd1_3_palavrinhas", "3 Palavrinhas", "video_dvd1_tres_palavrinhas", true));

        // DVD 2
        songList.add(new Song("dvd2_deus_e_bom_pra_mim", "Deus é Bom Pra Mim", "video_dvd2_deus_e_bom_pra_mim", true));
        songList.add(new Song("dvd2_trenzinho", "Trenzinho", "video_dvd2_trenzinho", true));

        // DVD 3
        songList.add(new Song("dvd3_dentro_fora_alto_embaixo", "Por Dentro, Fora, Alto, Embaixo", "video_dvd3_dentro_fora_alto_embaixo", true));
        songList.add(new Song("dvd3_meu_bom_pastor", "Meu Bom Pastor", "video_dvd3_meu_bom_pastor", true));

        // Hora de Dormir
        songList.add(new Song("dormir_o_sabao", "O Sabão", "video_dormir_o_sabao", true));
        songList.add(new Song("dormir_3_palavrinhas", "Deus é Amor", "video_dormir_tres_palavrinhas", true));

        // The Three Little Words (Inglês)
        songList.add(new Song("tlw_soap", "Soap", "video_tlw_soap", true));
        songList.add(new Song("tlw_3_little_words", "3 Little Words", "video_tlw_three_little_words", true));
    }
}
