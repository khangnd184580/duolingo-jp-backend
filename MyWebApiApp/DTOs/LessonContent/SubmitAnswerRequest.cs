namespace MyWebApiApp.DTOs.LessonContent
{
    public class SubmitAnswerRequest
    {
        public int QuestionId { get; set; }
        public int SelectedOptionId { get; set; }
    }
}
