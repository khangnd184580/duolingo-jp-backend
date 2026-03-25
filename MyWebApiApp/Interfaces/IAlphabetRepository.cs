using MyWebApiApp.DTOs.Alphabet;
using MyWebApiApp.Models;

namespace MyWebApiApp.Interfaces
{
    public interface IAlphabetRepository
    {
        Task<List<AlphabetResponse>> GetAllHiraganaAsync();
        Task<List<AlphabetResponse>> GetAllKatakataAsync();
        Task<List<AlphabetResponse>> GetAllKanjiAsync(string? level);
    }
}
