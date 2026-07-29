using MoneyTracker.Models;

namespace MoneyTracker.Service
{
    public interface INoteService
    {
        Task<IEnumerable<NoteModel>> GetAllNotesAsync();
        Task<IEnumerable<NoteModel>> GetNotesByDateAsync(DateTime date);
        Task<string> CreateNoteAsync(NoteModel note);
        Task<string> UpdateNoteAsync(NoteModel note);
        Task<string> DeleteNoteAsync(int notesId);
        Task<IEnumerable<NoteModel>> GetNotesByUserIdAsync(int userId);

    }
}
