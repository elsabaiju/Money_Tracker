namespace MoneyTracker.Models
{
    public class NoteModel
    {
        public int NotesId { get; set; }
        public int UserId { get; set; }
        public DateTime Date { get; set; }
        public string Notes { get; set; }

    }
}
