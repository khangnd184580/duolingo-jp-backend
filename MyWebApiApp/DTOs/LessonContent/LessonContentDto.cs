namespace MyWebApiApp.DTOs.LessonContent
{
    public class LessonContentDto
    {
        public int AttemptId { get; set; }
        public List<QuestionDto> Questions { get; set; }
    }
}
