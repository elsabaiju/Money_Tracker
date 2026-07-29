using Dapper;
using MoneyTracker.Services;
using MoneyTracker.Models;
using MoneyTracker.Models;
using System.Data;
using MoneyTracker.Contract;
using MoneyTracker.Service;

namespace MoneyTracker.Services
{
    public class NoteServices : INoteService
    {
        private readonly IDbConnection _db;

        public NoteServices(IDbConnection db)
        {
            _db = db;
        }

        public async Task<IEnumerable<NoteModel>> GetAllNotesAsync()
        {
            var sql = "SELECT * FROM notes";
            return await _db.QueryAsync<NoteModel>(sql);
        }

        public async Task<IEnumerable<NoteModel>> GetNotesByUserIdAsync(int userId)
        {
            var sql = "SELECT * FROM notes WHERE userid = @UserId";
            return await _db.QueryAsync<NoteModel>(sql, new { UserId = userId });
        }


        public async Task<IEnumerable<NoteModel>> GetNotesByDateAsync(DateTime date)
        {
            var sql = "SELECT * FROM notes WHERE date = @Date";
            return await _db.QueryAsync<NoteModel>(sql, new { Date = date });
        }

        public async Task<string> CreateNoteAsync(NoteModel note)
        {
            var sql = @"INSERT INTO notes (userid, date, notes)
                        VALUES (@UserId, @Date, @Notes)";
            var result = await _db.ExecuteAsync(sql, note);
            return result > 0 ? "Note created successfully" : "Failed to create note";
        }

        public async Task<string> UpdateNoteAsync(NoteModel note)
        {
            var sql = @"UPDATE notes 
                        SET userid = @UserId, date = @Date, notes = @Notes 
                        WHERE notesid = @NotesId";
            var result = await _db.ExecuteAsync(sql, note);
            return result > 0 ? "Note updated successfully" : "Failed to update note";
        }

        public async Task<string> DeleteNoteAsync(int notesId)
        {
            var sql = "DELETE FROM notes WHERE notesid = @NotesId";
            var result = await _db.ExecuteAsync(sql, new { NotesId = notesId });
            return result > 0 ? "Note deleted successfully" : "Failed to delete note";
        }
    }
}
