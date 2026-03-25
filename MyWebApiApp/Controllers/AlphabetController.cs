using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyWebApiApp.Data;
using MyWebApiApp.DTOs.Alphabet;
using MyWebApiApp.Interfaces;
using System;

namespace MyWebApiApp.Controllers
{
    [Route("api/alphabets")]
    [ApiController]
    public class AlphabetController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly IAlphabetRepository _alphabetRepo;

        public AlphabetController(ApplicationDbContext context, IAlphabetRepository alphabetRepo)
        {
            _context = context;
            _alphabetRepo = alphabetRepo;
        }

        [HttpGet("hiragana")]
        public async Task<IActionResult> GetHiragana()
        {
            var hiraganaAlphabets = await _alphabetRepo.GetAllHiraganaAsync();
            return Ok(hiraganaAlphabets);
        }

        [HttpGet("katakana")]
        public async Task<IActionResult> GetKatakana()
        {
            var katakanaAlphabets = await _alphabetRepo.GetAllKatakataAsync();
            return Ok(katakanaAlphabets);
        }

        [HttpGet("kanji")]
        public async Task<IActionResult> GetKanji([FromQuery] string? level)
        {
            var kanjiAlphabets = await _alphabetRepo.GetAllKanjiAsync(level);
                
            return Ok(kanjiAlphabets);

        }
    }
}
