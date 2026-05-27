namespace TiaMcpServer.Siemens
{
    // Snapshot returned by Portal.GetMultiuserStatus(). Lock fields are nullable because
    // the LockStateProvider lookup walks the Engineering Object Model and degrades
    // gracefully if the Project Server is unreachable or the project can't be correlated.
    public class MultiuserStatus
    {
        public string? ProjectName { get; set; }
        public string? SessionName { get; set; }
        public string? LocalSessionPath { get; set; }
        public bool IsUpToDate { get; set; }

        // True iff the lock-state lookup succeeded. When false, the two fields below are null.
        public bool LockLookupAvailable { get; set; }
        public bool? IsProjectLocked { get; set; }
        public string? LockOwner { get; set; }
    }
}
