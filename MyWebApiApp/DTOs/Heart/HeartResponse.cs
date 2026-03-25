namespace MyWebApiApp.DTOs.Heart
{
    public class HeartResponse
    {
        public int CurrentHearts { get; set; }
        public int MaxHearts { get; set; }
        public DateTime? NextRefillTime { get; set; }
    }
}
