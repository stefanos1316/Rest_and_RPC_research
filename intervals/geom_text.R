library("ggplot2")

df <- data.frame(
  Time = c(55, 55,# C# gRPC
           27, 27,# C# RPC
           44, 44, # C# Rest
           28, 28, # Go gRPC
           16, 16, # Go RPC
           19, 19, # Go Rest
           35, 35, # Java gRPC
           42, 42, # Java Rest
           3, 3, # JavaScript gRPC
           10, 10, # JavaScript RPC
           10, 10, # JavaScript Rest
           479, 479, # PHP gRPC
           67, 67, # PHP RPC
           628, 628, # PHP Rest 
           16, 16, # Python gRPC
           73, 73, # Python RPC
           78, 78, # Python Rest
           55, 55, # Ruby gRPC
           43, 43, # Ruby RPC
           304, 304 #  Ruby Rest
           ),
  Energy = c(65.6, 105.2, # C# gRPC
             399.9, 364,# C# RPC
             1206.6, 789.4, # C# Rest
             99, 105.8, # Go gRPC
             84.8, 70.4, # Go RPC
             94.1, 79, # Go Rest
             451.5, 364, # Java gRPC
             687, 617.8, # Java Rest
             28.2, 27, # JavaScript gRPC
             36.2, 32.3, # JavaScript RPC
             88.1, 31.4, # JavaScript Rest
             2543.9, 1291.3, # PHP gRPC
             930.5, 1214.6, # PHP RPC
             1903, 2274.5, # PHP Rest
             606.7, 319.5, # Python gRPC
             319.5, 347, # Python RPC
             637, 370, # Python Rest
             139.4, 61.6, # Ruby gRPC
             458.2, 513.5, # Ruby RPC
             1899.2, 2191.2 # Ruby Rest
             ),
  text = c(
    "C# gRPC Client", "C# gRPC Server", 
    "C# RPC Client", "C# RPC Server",
    "C# Rest Client", "C# Rest Server",
    "Go gRPC Client", "Go gRPC Server",
    "Go RPC Client", "Go RPC Server",
    "Go Rest Client", "Go Rest Server",
    "Java gRPC Client", "Java gRPC Server",
    "Java Rest Client", "Java Rest Server",
    "JavaScript gRPC Client", "JavaScript gRPC Server",
    "JavaScript RPC Client", "JavaScript RPC Server",
    "JavaScript Rest Client", "JavaScript Rest Server",
    "PHP gRPC Client", "PHP gRPC Server",
    "PHP RPC Client", "PHP RPC Server",
    "PHP Rest Client", "PHP Rest Server",
    "Python gRPC Client", "Python gRPC Server",
    "Python RPC Client", "Python RPC Server",
    "Python Rest Client", "Python Rest Server",
    "Ruby gRPC Client", "Ruby gRPC Server",
    "Ruby RPC Client", "Ruby RPC Server",
    "Ruby Rest Client", "Ruby Rest Server"
  )
)
ggtitle("Energy-Delay Comparison of Intel Platform Implementations")
ggplot(df, aes(Time, Energy)) + geom_text(aes(label = text))
ggplot(df, aes(Time, Energy)) + geom_text(aes(label = text), vjust = "inward", hjust = "inward")
pdf("~/ggplot.pdf")
print(ggplot)
dev.off()
