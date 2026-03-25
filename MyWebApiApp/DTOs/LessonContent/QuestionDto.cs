namespace MyWebApiApp.DTOs.LessonContent
{
    public class QuestionDto
    {
        public int QuestionId { get; set; }
        public string Content { get; set; }
        public List<OptionDto> Options { get; set; }
    }
}
