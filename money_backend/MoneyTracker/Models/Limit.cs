
namespace MoneyTracker.Models
{
    public class Limit
    {
        public int LimitId { get; set; }
        public int UserId { get; set; }
        public DateTime Date { get; set; }
        public decimal LimitAmount { get; set; }    }

}
