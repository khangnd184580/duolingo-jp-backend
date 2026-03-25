using MyWebApiApp.DTOs.Alphabet;
using MyWebApiApp.Models;

namespace MyWebApiApp.Mappers
{
    public static class AlphabetMappers
    {
        public static AlphabetResponse ToAlphabetResponse(this Alphabet alphabetModel)
        {
            return new AlphabetResponse
            {
                AlphabetId = alphabetModel.AlphabetId,
                Character = alphabetModel.Character,
                Type = alphabetModel.Type,
                Level = alphabetModel.Level,
                Meaning = alphabetModel.Meaning
            };
        }
    }
}
