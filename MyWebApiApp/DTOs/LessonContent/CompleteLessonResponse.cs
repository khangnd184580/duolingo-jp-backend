namespace MyWebApiApp.DTOs.LessonContent
{
    public class CompleteLessonResponse
    {
        public int TotalQuestions { get; set; }
        public int CorrectAnswers { get; set; }
        public bool IsPassed { get; set; }
        public int EarnedXP { get; set; }
        public double Accuracy { get; set; }
    }
}
