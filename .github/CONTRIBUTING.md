# CONTRIBUTING

1. [Reporting Issues](#reporting-issues)
2. [Introduction](#introduction)
3. [Getting Started](#getting-started)
4. [Meet the Team](#meet-the-team)
	1. [Head Developer](#head-developer)
	2. [Maintainers](#maintainers)
5. [Yogstation GitHub Guidelines](#yogstation-github-guidelines)
6. [Development Guides](#development-guides)
7. [Pull Request Process](#pull-request-process)
8. [Porting features/sprites/sounds/tools from other codebases](#porting-featuresspritessoundstools-from-other-codebases)
9. [A word on Git](#a-word-on-git)

## Reporting Issues

See [this page](http://tgstation13.org/wiki/Reporting_Issues) for a guide and format to issue reports.

## Introduction

Hello and welcome to Yogstation's contributing page. You are here because you are curious or interested in contributing - thank you! Everyone is free to contribute to this project as long as they follow the simple guidelines and specifications below; at Yogstation, we strive to maintain code stability and maintainability, and to do that, we need all pull requests to hold up to those specifications. It's in everyone's best interests - including yours! - if the same bug doesn't have to be fixed twice because of duplicated code.

First things first, we want to make it clear how you can contribute (if you've never contributed before), as well as the kinds of powers the team has over your additions, to avoid any unpleasant surprises if your pull request is closed for a reason you didn't foresee.

## Getting Started

Yogstation doesn't have a list of goals and features to add; we instead allow freedom for contributors to suggest and create their ideas for the game. That doesn't mean we aren't determined to squash bugs, which unfortunately pop up a lot due to the deep complexity of the game. Here are some useful starting guides, if you want to contribute or if you want to know what challenges you can tackle with zero knowledge about the game's code structure.

If you want to contribute the first thing you'll need to do is [set up Git](https://wiki.yogstation.net/wiki/Setting_up_git) so you can download the source code.

We have a [list of guides on the wiki](https://wiki.yogstation.net/wiki/Guides#Development_and_Contribution_Guides) that will help you get started contributing to Yogstation with Git and Dream Maker. For beginners, it is recommended you work on small projects like bug fixes at first. If you need help learning to program in BYOND, check out this [repository of resources](http://www.byond.com/developer/articles/resources).

You can of course, as always, ask for help in #coder-public on the [discord](https://discord.gg/0keg6hQH05Ha8OfO). We're just here to have fun and help out, so please don't expect professional support.

## Meet the Team

### Head Developer

The Head Developer(s) are responsible for controlling, adding, and removing maintainers from the project. In addition to filling the role of a normal maintainer, they have sole authority on who becomes a maintainer, as well as who remains a maintainer and who does not.

### Maintainers

Maintainers are quality control. If a proposed pull request doesn't meet the specifications laid out in this document, they can request you to change it, or simply just close the pull request. Maintainers are required to wait 24 hours before closing a pull request, and must give a reason for closing the pull request.

Maintainers can revert your changes if they feel they are not worth maintaining or if they did not live up to the quality specifications.

## Yogstation GitHub Guidelines

### General Rules

**Yogstation is an open source community-driven project that allows everybody to contribute their ideas towards making rounds on Space Station 13 as fun as possible by means of pull requests and issue reports to the main repository.**

**Although we allow conversation on GitHub in Pull Requests/Issues, we ask that all contributors and maintainers maintain a sense of decorum and respect the author and other people contributing to the discussion.** If someone is constantly contributing negative statements or is not constructive in their criticism they may be asked to stop or have their right to contribute removed in the future.

**The GitHub Terms and Conditions must be followed.** Failure to follow the terms and conditions of GitHub may result in your exclusion from contribution in the future. 

**We do not require people to be signed up on the forums or Discord in order to contribute to the GitHub; however, there must be a way for maintainers to be able to contact you, either via Discord (preferably) or e-mail when concerns with identity are found and need to be resolved.** Being banned from the server does not automatically ban you from GitHub and vice versa; however, this is up to the discretion of the head developers. Your pull requests may all be placed on hold until you accept this request for communication.

### Contributors

**When you are creating a Pull Request/Issue Report**, please make sure you name the Pull Request/Issue something relevant to what is being changed, added, or removed. Do not attempt to mislead people about the content of the Pull Request/Issue. Make sure you fill out any applicable templates as clearly and concisely as possible, and link any relevant issues your Pull Request solves.

**We do not limit the amount of Pull Requests which can be submitted per day**; however, please do not submit more than is necessary. Additionally, please do not harass any member of the development team to expedite or merge your Pull Request. In certain circumstances, such as the case of a game breaking bug or issue, please reach out and inform them as soon as possible.

**We allow users to create draft Pull Requests in order to have time to work on features and solicit feedback on those features**; however, there will be a limit of 2 draft Pull Requests per person, as we want people to finish their projects before moving onto others as soon as possible.

**In regards to Revert Pull Requests**, these should only be opened if there is a reason for the reversion ie. the feature is broken or is not as expected when it was merged. Otherwise please wait at least 48 hours before reversing a change.

### Maintainers

**As a maintainer, you are a representative of the development team, as such you should act with a somewhat professional manner when dealing with contributions, including constructively commenting on PRs.**

**All maintainers should follow set standards for handling Pull Requests.** These standards include waiting 24 hours before merging or closing a Pull Request, as well as merging only Pull Requests that fall under your area of expertise (i.e. an Art Maintainer should not merge code, and a Code Maintainer should not merge art.) Lastly, revert Pull Requests should only be merged by a Head Developer. The above limitations do not apply to round-breaking or repo-breaking changes; however, please notify any head developers if this occurs.

**All maintainers should encourage discourse and collaboration.** As such, maintainers should only close draft Pull Requests if:
* A contributor has more than 2 draft Pull Requests open, in which the oldest draft Pull Request should be closed until the author closes another.
* A contributor has opened a draft Pull Request that has no changes present in it after the initial 24 hours.
* A contributor has not contributed to their draft Pull Request in a week’s time.
* The Pull Request was opened with inadequate rationale or is lacking naming or following existing guidelines.


**If a Maintainer/Director gets banned from the server/Discord, there will be an automatic review process triggered.** During this time access to GitHub merging and in-game ranks will be removed until the review is complete. After this review, roles and permissions may be returned depending on the result.

### Contributor-Maintainer Disputes

**If you have any complaints about maintainers or contributors you can use the GitHub report function**; however, abuse of this feature will be addressed if needed.

**You may also raise an issue on discord by going to the #head-dev-complaints channel and creating a private thread**, then pinging head developers to make sure they are notified.

**These policies are enforced by the Head Developer(s) and are subject to change at their discretion, with or without notification to the general public.**

## Development Guides

#### Writing readable code 
[Style guide](./guides/STYLE.md)

#### Writing sane code 
[Code standards](./guides/STANDARDS.md)

#### Writing understandable code 
[Autodocumenting code](./guides/AUTODOC.md)

## Pull Request Process

There is no strict process when it comes to merging pull requests. Pull requests will sometimes take a while before they are looked at by a maintainer; the bigger the change, the more time it will take before they are accepted into the code. Every team member is a volunteer who is giving up their own time to help maintain and contribute, so please be courteous and respectful. Here are some helpful ways to make it easier for you and for the maintainers when making a pull request.

* Make sure your pull request complies to the requirements outlined in [this guide](http://tgstation13.org/wiki/Getting_Your_Pull_Accepted)

* You are going to be expected to document all your changes in the pull request. Failing to do so will mean delaying it as we will have to question why you made the change. On the other hand, you can speed up the process by making the pull request readable and easy to understand, with diagrams or before/after data.

* We ask that you use the changelog system to document your player facing changes, which prevents our players from being caught unaware by said changes - you can find more information about this [on this wiki page](http://tgstation13.org/wiki/Guide_to_Changelogs).

* If you are proposing multiple changes, which change many different aspects of the code, you are expected to section them off into different pull requests in order to make it easier to review them and to deny/accept the changes that are deemed acceptable.

* If your pull request is accepted, the code you add no longer belongs exclusively to you but to everyone; everyone is free to work on it, but you are also free to support or object to any changes being made, which will likely hold more weight, as you're the one who added the feature. It is a shame this has to be explicitly said, but there have been cases where this would've saved some trouble.

* Please explain why you are submitting the pull request, and how you think your change will be beneficial to the game. Failure to do so will be grounds for rejecting the PR.

* If your pull request is not finished make sure it is at least testable in a live environment. Pull requests that do not at least meet this requirement will be closed. You may request a maintainer reopen the pull request when you're ready, or make a new one.

* While we have no issue helping contributors (and especially new contributors) bring reasonably sized contributions up to standards via the pull request review process, larger contributions are expected to pass a higher bar of completeness and code quality *before* you open a pull request. Maintainers may close such pull requests that are deemed to be substantially flawed. You should take some time to discuss with maintainers or other contributors on how to improve the changes.

## Porting features/sprites/sounds/tools from other codebases

If you are porting features/tools from other codebases, you must give them credit where it's due. Typically, crediting them in your pull request and the changelog is the recommended way of doing it. Take note of what license they use though, porting stuff from AGPLv3 and GPLv3 codebases are allowed.

Regarding sprites & sounds, you must credit the artist and possibly the codebase. All yogstation assets including icons and sound are under a [Creative Commons 3.0 BY-SA license](https://creativecommons.org/licenses/by-sa/3.0/) unless otherwise indicated. However if you are porting assets from GoonStation or usually any assets under the [Creative Commons 3.0 BY-NC-SA license](https://creativecommons.org/licenses/by-nc-sa/3.0/) are to go into the 'goon' folder of the yogstation codebase.

## A word on Git
All .dmm .dm .md .txt .html are required to end with CRLF(DOS/WINDOWS) line endings,git will enforce said line endings automatically. Other file types have non enforced line endings.
