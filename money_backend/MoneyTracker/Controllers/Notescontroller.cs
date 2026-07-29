using Microsoft.AspNetCore.Mvc;
using MoneyTracker.Models;
using MoneyTracker.Service;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MoneyTracker.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class NoteController : ControllerBase
    {
        private readonly INoteService _noteService;

        public NoteController(INoteService noteService)
        {
            _noteService = noteService;
        }

        // Create
        [HttpPost("create")]
        public async Task<IActionResult> CreateNote(
            [FromQuery] int userid,
            [FromQuery] DateTime date,
            [FromQuery] string notes)
        {
            var note = new NoteModel
            {
                UserId = userid,
                Date = date,
                Notes = notes
            };

            var result = await _noteService.CreateNoteAsync(note);
            return Ok(result);
        }

        // Update
        [HttpPost("update")]
        public async Task<IActionResult> UpdateNote(
            [FromQuery] int notesid,
            [FromQuery] int userid,
            [FromQuery] DateTime date,
            [FromQuery] string notes)
        {
            var updatedNote = new NoteModel
            {
                NotesId = notesid,
                UserId = userid,
                Date = date,
                Notes = notes
            };

            var result = await _noteService.UpdateNoteAsync(updatedNote);
            return Ok(result);
        }

        // Delete
        [HttpPost("delete")]
        public async Task<IActionResult> DeleteNote([FromQuery] int notesid)
        {
            var result = await _noteService.DeleteNoteAsync(notesid);
            return Ok(result);
        }

        // Get all
        [HttpPost("all")]
        public async Task<IEnumerable<NoteModel>> GetAllNotes()
        {
            return await _noteService.GetAllNotesAsync();
        }

        [HttpPost("byuserid")]
        public async Task<IEnumerable<NoteModel>> GetNotesByUserId([FromQuery] int userId)
        {
            // SQL query: SELECT * FROM notes WHERE userid = @UserId
            var notes = await _noteService.GetNotesByUserIdAsync(userId);
            return notes;
        }


        // Get by date
        [HttpPost("bydate")]
        public async Task<IEnumerable<NoteModel>> GetNotesByDate([FromQuery] DateTime date)
        {
            return await _noteService.GetNotesByDateAsync(date);
        }
    }
}
