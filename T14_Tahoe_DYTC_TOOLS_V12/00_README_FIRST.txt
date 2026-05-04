USB 없이 부팅 만들기

현재 이 Mac에서는 T14 내장 SN850/CachyOS/macOS 디스크가 안 보여서 직접 복사하지 않았음.
T14에서 아래 순서대로 실행.

가장 쉬운 순서
1. T14를 지금 USB로 macOS 부팅
2. USB 도구 폴더에서 실행:
   10_INSTALL_OC_TO_INTERNAL_EFI_FROM_MACOS.command
3. 재부팅 후 ThinkPad F12/BIOS에서 OpenCore가 보이면 OpenCore를 1순위로 설정
4. OpenCore 항목이 안 보이면 CachyOS로 부팅 후 실행:
   11_ADD_OPENCORE_BOOT_ENTRY_FROM_CACHYOS.sh

안전장치
- 10번 스크립트는 내장 디스크가 900GB 이상이고 APFS + Linux/CachyOS 계열 파티션이 같이 보일 때만 진행함.
- GRUB/CachyOS는 지우지 않고 EFI/OC만 복사함.
- 내장 EFI 전체 백업은 Backups/Internal_EFI_BEFORE_OC_* 에 저장됨.

절대 하지 말 것
- 내장 EFI 포맷 금지
- /EFI 전체 삭제 금지
- GRUB/CachyOS 폴더 삭제 금지
