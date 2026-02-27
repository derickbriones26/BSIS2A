-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Feb 27, 2026 at 07:53 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.1.25

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `schooldb`
--

-- --------------------------------------------------------

--
-- Table structure for table `courses`
--

CREATE TABLE `courses` (
  `CourseID` int(11) NOT NULL,
  `CourseName` varchar(100) NOT NULL,
  `Department` varchar(50) DEFAULT 'General Studies'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `courses`
--

INSERT INTO `courses` (`CourseID`, `CourseName`, `Department`) VALUES
(1, 'Database Management', 'Computer Studies'),
(2, 'Data Structures', 'Computer Studies'),
(3, 'Web Development', 'Information Technology'),
(4, 'Systems Analysis', 'Information Systems'),
(5, 'Network Security', 'Information Technology');

-- --------------------------------------------------------

--
-- Table structure for table `enrollments`
--

CREATE TABLE `enrollments` (
  `EnrollmentID` int(11) NOT NULL,
  `StudentID` int(11) NOT NULL,
  `CourseID` int(11) NOT NULL,
  `EnrollmentDate` date DEFAULT curdate()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `enrollments`
--

INSERT INTO `enrollments` (`EnrollmentID`, `StudentID`, `CourseID`, `EnrollmentDate`) VALUES
(1, 1, 1, '2026-02-07'),
(2, 1, 3, '2026-02-07'),
(3, 2, 4, '2026-02-07'),
(5, 3, 5, '2026-02-07'),
(6, 4, 1, '2026-02-07'),
(7, 5, 4, '2026-02-07'),
(8, 6, 3, '2026-02-07'),
(10, 7, 2, '2026-02-07'),
(11, 8, 4, '2026-02-07'),
(12, 9, 3, '2026-02-07'),
(13, 10, 1, '2026-02-07'),
(14, 10, 2, '2026-02-07'),
(15, 3, 1, '2026-02-07');

-- --------------------------------------------------------

--
-- Table structure for table `students`
--

CREATE TABLE `students` (
  `StudentID` int(11) NOT NULL,
  `Name` varchar(100) NOT NULL,
  `Age` int(11) DEFAULT NULL CHECK (`Age` >= 16 and `Age` <= 70),
  `Course` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `students`
--

INSERT INTO `students` (`StudentID`, `Name`, `Age`, `Course`) VALUES
(1, 'Alexandra Chen', 20, 'BS Computer Science'),
(2, 'Marcus Rivera', 22, 'BS Information Systems'),
(3, 'Sophia Williams', 21, 'BS Information Technology'),
(4, 'James Wilson', 19, 'BS Computer Science'),
(5, 'Olivia Martinez', 23, 'BS Information Systems'),
(6, 'Liam Brown', 20, 'BS Information Technology'),
(7, 'Isabella Garcia', 22, 'BS Computer Science'),
(8, 'Ethan Lee', 21, 'BS Information Systems'),
(9, 'Mia Johnson', 19, 'BS Information Technology'),
(10, 'Noah Davis', 24, 'BS Computer Science');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `courses`
--
ALTER TABLE `courses`
  ADD PRIMARY KEY (`CourseID`),
  ADD UNIQUE KEY `CourseName` (`CourseName`);

--
-- Indexes for table `enrollments`
--
ALTER TABLE `enrollments`
  ADD PRIMARY KEY (`EnrollmentID`),
  ADD UNIQUE KEY `unique_enrollment` (`StudentID`,`CourseID`),
  ADD KEY `CourseID` (`CourseID`);

--
-- Indexes for table `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`StudentID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `courses`
--
ALTER TABLE `courses`
  MODIFY `CourseID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `enrollments`
--
ALTER TABLE `enrollments`
  MODIFY `EnrollmentID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `students`
--
ALTER TABLE `students`
  MODIFY `StudentID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `enrollments`
--
ALTER TABLE `enrollments`
  ADD CONSTRAINT `enrollments_ibfk_1` FOREIGN KEY (`StudentID`) REFERENCES `students` (`StudentID`) ON DELETE CASCADE,
  ADD CONSTRAINT `enrollments_ibfk_2` FOREIGN KEY (`CourseID`) REFERENCES `courses` (`CourseID`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
