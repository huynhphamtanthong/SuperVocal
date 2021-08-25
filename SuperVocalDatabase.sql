create database SuperVocal
go
use SuperVocal

create table Candidates (
    ID int not null primary key,
    Name nvarchar(50) not null,
    State char(1) not null check (State = 'o' or State = 'r'),
)

create table Monitors (
    ID int not null primary key,
    Name nvarchar(50) not null,
)

create table Interviews (
    OfficialID int not null references Candidates(ID),
    ReserveID int not null references Candidates(ID),
    primary key (OfficialID, ReserveID),
)

create table DuetTeams (
    OfficialID int not null unique,
    ReserveID int not null unique,
    Passed int not null default 0,
    primary key (OfficialID, ReserveID),
    foreign key (OfficialID, ReserveID) references Interviews(OfficialID, ReserveID),
)

create table TrioTeams (
    OfficialID int not null unique,
    ReserveID1 int not null unique,
    ReserveID2 int not null unique,
    Passed int not null default 0,
    primary key (OfficialID, ReserveID1, ReserveID2),
    foreign key (OfficialID, ReserveID1) references DuetTeams(OfficialID, ReserveID),
)

go

insert into candidates values(1,'Nguyen Van Q','O')
insert into candidates values(2,'Nguyen Van W','O')
insert into candidates values(3,'Nguyen Van E','O')
insert into candidates values(4,'Nguyen Van R','O')
insert into candidates values(5,'Nguyen Van T','O')
insert into candidates values(6,'Nguyen Van Y','O')
insert into candidates values(7,'Nguyen Van U','R')
insert into candidates values(8,'Nguyen Van I','R')
insert into candidates values(9,'Nguyen Van O','R')
insert into candidates values(10,'Nguyen Van P','R')
insert into candidates values(11,'Nguyen Van A','R')
insert into candidates values(12,'Nguyen Van S','R')
insert into candidates values(13,'Nguyen Van D','R')
insert into candidates values(14,'Nguyen Van F','R')
insert into candidates values(15,'Nguyen Van G','R')
insert into candidates values(16,'Nguyen Van H','R')
insert into candidates values(17,'Nguyen Van j','R')
insert into candidates values(18,'Nguyen Van K','R')
insert into candidates values(19,'Nguyen Van K','R')
insert into candidates values(20,'Nguyen Van L','R')
insert into candidates values(21,'Nguyen Van Z','R')
insert into candidates values(22,'Nguyen Van X','R')
insert into candidates values(23,'Nguyen Van C','R')
insert into candidates values(24,'Nguyen Van V','R')
insert into candidates values(25,'Nguyen Van B','R')
insert into candidates values(26,'Nguyen Van N','R')
insert into candidates values(27,'Nguyen Van M','R')
insert into candidates values(28,'Nguyen Van qq','R')
insert into candidates values(29,'Nguyen Van ww','R')
insert into candidates values(30,'Nguyen Van ee','R')
insert into candidates values(31,'Nguyen Van rr','R')
insert into candidates values(32,'Nguyen Van tt','R')
insert into candidates values(33,'Nguyen Van kk','R')
insert into candidates values(34,'Nguyen Van WW','R')

insert into Monitors values (1,'Quan')
insert into Monitors values (2,'Quan2')
insert into Monitors values (3,'Quan3')

go

create procedure sp_listAllReserveCandidates
as
    select * 
    from Candidates 
    where State = 'r'

go

create procedure sp_listAllOfficialCandidates
as
    select * 
    from Candidates 
    where State = 'o'

go

create procedure sp_listAllMonitors
as
    select * 
    from Monitors

go

create procedure sp_listAllDuetTeams
as
    select * 
    from DuetTeams

go

create procedure sp_listAllTrioTeams
as 
    select * 
    from TrioTeams

go

create procedure sp_listAllInterviews
as 
    select * 
    from Interviews

go

create procedure sp_addNewInterview(@OfficialID int, @ReserveID int)
as
begin transaction
begin try
    if not exists (
        select * 
        from Candidates c
        where c.ID = @OfficialID
        and State = 'o'
    )
        throw 4, 'The ID for this official candidate does not exist', 1;

    if not exists (
        select * 
        from Candidates c
        where c.ID = @ReserveID
        and state = 'r'
    )
        throw 5, 'The ID for this reserve candidate does not exist', 1;

    if exists (
        select * 
        from Interviews
        where OfficialID = @OfficialID
        and ReserveID = @ReserveID
    )
        throw 6, 'These two candidates has already been in an interview', 1;

    insert into Interviews (OfficialID,ReserveID) 
    values
        (@OfficialID, @ReserveID)
        
    commit transaction
end try
begin catch
    rollback transaction;
    throw;
end catch

go

create procedure sp_addNewDuetTeam(@OfficialID int, @ReserveID int)
as
begin transaction
begin try
    if not exists (
        select * 
        from Candidates c
        where c.ID = @OfficialID
        and State = 'o'
    )
        throw 1, 'The ID for this official candidate does not exist', 1;

    if not exists (
        select * 
        from Candidates c
        where c.ID = @ReserveID
        and state='r'
    )
        throw 2, 'The ID for this reserve candidate does not exist', 1;

    if not exists (
        select * 
        from Interviews
        where OfficialID = @OfficialID
        and ReserveID = @ReserveID
    )
        throw 3, 'These two candidates has not been in any interviews', 1;

    if exists (
        select * 
        from DuetTeams
        where OfficialID = @OfficialID
    )
        throw 7, 'This official candidate has been selected into a duet team', 1;

    if exists (
        select * 
        from DuetTeams
        where ReserveID = @ReserveID
    )
        throw 8, 'This reserve candidate has been selected into a duet team', 1;

    insert into DuetTeams (OfficialID,ReserveID) 
    values
        (@OfficialID, @ReserveID)

    commit transaction
end try
begin catch
    rollback transaction;
    throw;
end catch

go

create procedure sp_judgeDuetTeams(
    @OfficialID1 int,
    @ReserveID1 int,
    @OfficialID2 int,
    @ReserveID2 int,
    @OfficialID3 int,
    @ReserveID3 int
)
as
begin transaction
begin try
    if not exists (
        select * 
        from DuetTeams
        where OfficialID = @OfficialID1
        and ReserveID = @ReserveID1
    )
        throw 9, 'The first duet team does not exist', 1;

    if not exists (
        select * 
        from DuetTeams
        where OfficialID = @OfficialID2
        and ReserveID = @ReserveID2
    )
        throw 10, 'The second duet team does not exist', 1;
    
    if not exists (
        select * 
        from DuetTeams
        where OfficialID = @OfficialID3
        and ReserveID = @ReserveID3
    )
        throw 11, 'The third duet team does not exist', 1;

    if exists (
        select * 
        from DuetTeams
        where Passed = 1
    )
        update DuetTeams
        set Passed = 0

    update DuetTeams
    set Passed = 1
    where OfficialID = @OfficialID1
    and ReserveID = @ReserveID1

    update DuetTeams
    set Passed = 1
    where OfficialID = @OfficialID2
    and ReserveID = @ReserveID2

    update DuetTeams
    set Passed = 1
    where OfficialID = @OfficialID3
    and ReserveID = @ReserveID3

    commit transaction
end try
begin catch
    rollback transaction;
    throw;
end catch

go

create procedure sp_addNewTrioTeam(@OfficialID int, @ReserveID1 int, @ReserveID2 int)
as 
begin transaction
begin try
    if not exists (
        select * 
        from Candidates c
        where c.ID = @OfficialID
        and State = 'o'
    )
        throw 11, 'The ID for this official candidate does not exist', 1;

    if not exists (
        select * 
        from Candidates c
        where c.ID = @ReserveID1
        and state='r'
    )
        throw 12, 'The ID for the first reserve candidate does not exist', 1;
        
    if not exists (
        select * 
        from Candidates c
        where c.ID = @ReserveID2
        and state='r'
    )
        throw 13, 'The ID for the second reserve candidate does not exist', 1;

    if not exists (
        select * 
        from DuetTeams
        where OfficialID = @OfficialID
        and ReserveID = @ReserveID1
    )
        throw 14, 'This duet team does not exists', 1;

    if exists (
        select * 
        from DuetTeams
        where OfficialID = @OfficialID
        and ReserveID = @ReserveID1
        and Passed = 0
    )
        throw 14, 'This duet team has not passed', 1;

    if exists (
        select * 
        from TrioTeams
        where OfficialID = @OfficialID
    )
        throw 15, 'This official candidate has been selected into a trio team', 1;

    if exists (
        select * 
        from TrioTeams
        where ReserveID1 = @ReserveID1
        or ReserveID2 = @ReserveID1
    )
        throw 16, 'The first reserve candidate has been selected into a trio team', 1;

    if exists (
        select * 
        from TrioTeams
        where ReserveID1 = @ReserveID2
        or ReserveID2 = @ReserveID2
    )
        throw 17, 'The second reserve candidate has been selected into a trio team', 1;

    insert into TrioTeams (OfficialID, ReserveID1, ReserveID2)
    values 
        (@OfficialID, @ReserveID1, @ReserveID2);

    commit transaction
end try
begin catch
    rollback transaction;
    throw;
end catch

go

create procedure sp_judgeTrioTeams(
    @OfficialID1 int,
    @ReserveID11 int,
    @ReserveID12 int,
    @OfficialID2 int,
    @ReserveID21 int,
    @ReserveID22 int
)
as
begin transaction
begin try
    if not exists (
        select * 
        from TrioTeams
        where OfficialID = @OfficialID1
        and ReserveID1 = @ReserveID11
        and ReserveID2 = @ReserveID12
    )
        throw 18, 'The first trio team does not exist', 1;

    if not exists (
        select * 
        from TrioTeams
        where OfficialID = @OfficialID2
        and ReserveID1 = @ReserveID21
        and ReserveID2 = @ReserveID22
    )
        throw 19, 'The second trio team does not exist', 1;

    if exists (
        select * 
        from TrioTeams
        where Passed = 1
    )
        update TrioTeams
        set Passed = 0

    update TrioTeams
    set Passed = 1
    where OfficialID = @OfficialID1
    and ReserveID1 = @ReserveID11
    and ReserveID2 = @ReserveID12

    update TrioTeams
    set Passed = 1
    where OfficialID = @OfficialID2
    and ReserveID1 = @ReserveID21
    and ReserveID2 = @ReserveID22

    commit transaction
end try
begin catch
    rollback transaction;
    throw;
end catch

go

-- exec sp_addNewInterview 1, 11;
-- exec sp_addNewInterview 1, 20;
-- exec sp_addNewInterview 1, 24;
-- exec sp_addNewInterview 2, 12;
-- exec sp_addNewInterview 2, 11;
-- exec sp_addNewInterview 3, 18;
-- exec sp_addNewInterview 4, 22;
-- exec sp_addNewInterview 4, 30;
-- exec sp_addNewInterview 5, 8;
-- exec sp_addNewInterview 5, 26;
-- exec sp_addNewInterview 6, 22;
-- exec sp_addNewInterview 6, 19;

-- exec sp_listAllInterviews;

-- exec sp_addNewDuetTeam 1, 11;
-- exec sp_addNewDuetTeam 2, 12;
-- exec sp_addNewDuetTeam 3, 18;
-- exec sp_addNewDuetTeam 4, 22;
-- exec sp_addNewDuetTeam 5, 8;
-- exec sp_addNewDuetTeam 6, 19;

-- exec sp_listAllDuetTeams;

-- exec sp_judgeDuetTeams 1, 11, 3, 18, 5, 8;
-- exec sp_listAllDuetTeams;

-- exec sp_addNewTrioTeam 1, 11, 12;
-- exec sp_addNewTrioTeam 3, 18, 19;
-- exec sp_addNewTrioTeam 5, 8, 10;


--use master
--drop database SuperVocal