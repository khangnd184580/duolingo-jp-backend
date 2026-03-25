namespace MyWebApiApp.DTOs.Friends
{
    public class FriendOperationResult
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
    }

    public class SendFriendRequestDto
    {
        public string Username { get; set; } = string.Empty;
    }

    public class FriendUserDto
    {
        public string UserId { get; set; } = string.Empty;
        public string Username { get; set; } = string.Empty;
        public string? AvatarUrl { get; set; }
    }

    public class FriendRequestIncomingDto
    {
        public int RequestId { get; set; }
        public string FromUserId { get; set; } = string.Empty;
        public string FromUsername { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
    }
}
